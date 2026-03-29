import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/*
# HELPER: GET BALANCE
*/
async function getBalance(yarn_lot_id) {
const result = await pool.query(
`     SELECT COALESCE(SUM(
      CASE 
        WHEN transaction_type IN ('inward','return') THEN quantity
        WHEN transaction_type IN ('issue','waste','party_return','setting') THEN -quantity
      END
    ),0) AS balance
    FROM yarn_ledger
    WHERE yarn_lot_id = $1
    `,
[yarn_lot_id]
);

return Number(result.rows[0].balance);
}

 /*

# YARN MASTER

*/
router.get("/", async (req, res) => {
const result = await pool.query(`     SELECT id, yarn_name, yarn_count, yarn_type
    FROM yarn_master
    ORDER BY yarn_name ASC
  `);
res.json(result.rows);
});

router.post("/", async (req, res) => {
const { yarn_name, yarn_count, yarn_type } = req.body;

if (!yarn_name) {
return res.status(400).json({ error: "Yarn name required" });
}

const result = await pool.query(
`INSERT INTO yarn_master (yarn_name, yarn_count, yarn_type)
     VALUES ($1,$2,$3)
     RETURNING *`,
[yarn_name, yarn_count, yarn_type]
);

res.json(result.rows[0]);
});

 /*

# INWARD

*/
router.post("/inward", async (req, res) => {
const { party_id, yarn_id, lot_no, challan_no, inward_date, quantity } = req.body;

if (!party_id || !yarn_id || !lot_no || !quantity) {
return res.status(400).json({ error: "Missing fields" });
}

try {
await pool.query("BEGIN");


const lot = await pool.query(
  `
  INSERT INTO yarn_lot 
  (party_id, yarn_id, lot_no, challan_no, inward_date, quantity_received)
  VALUES ($1,$2,$3,$4,$5,$6)
  RETURNING id
  `,
  [party_id, yarn_id, lot_no, challan_no, inward_date, quantity]
);

const lotId = lot.rows[0].id;

await pool.query(
  `
  INSERT INTO yarn_ledger
  (yarn_lot_id, transaction_type, quantity, remarks)
  VALUES ($1,'inward',$2,'Yarn inward entry')
  `,
  [lotId, quantity]
);

await pool.query("COMMIT");

res.json({ message: "Yarn inward added" });


} catch (err) {
await pool.query("ROLLBACK");
console.error(err);
res.status(500).json({ error: "Inward failed" });
}
});

 /*

# ISSUE

*/
router.post("/issue", async (req, res) => {
const { job_id, yarn_lot_id, quantity } = req.body;

if (!job_id || !yarn_lot_id || !quantity || quantity <= 0) {
return res.status(400).json({ error: "Invalid input" });
}

try {
await pool.query("BEGIN");


const balance = await getBalance(yarn_lot_id);

if (quantity > balance) {
  await pool.query("ROLLBACK");
  return res.status(400).json({ error: "Insufficient balance" });
}

await pool.query(
  `
  INSERT INTO yarn_ledger
  (yarn_lot_id, job_id, transaction_type, quantity, remarks)
  VALUES ($1,$2,'issue',$3,'Issued to job')
  `,
  [yarn_lot_id, job_id, quantity]
);

await pool.query("COMMIT");

res.json({ message: "Yarn issued" });


} catch (err) {
await pool.query("ROLLBACK");
console.error(err);
res.status(500).json({ error: "Issue failed" });
}
});

 /*

# RETURN (FROM JOB)

*/
router.post("/return", async (req, res) => {
const { job_id, yarn_lot_id, quantity } = req.body;

if (!job_id || !yarn_lot_id || !quantity) {
return res.status(400).json({ error: "Missing fields" });
}

await pool.query(
`     INSERT INTO yarn_ledger
    (yarn_lot_id, job_id, transaction_type, quantity, remarks)
    VALUES ($1,$2,'return',$3,'Yarn returned from job')
    `,
[yarn_lot_id, job_id, quantity]
);

res.json({ message: "Yarn returned" });
});

 /*

# PARTY RETURN (TO PARTY)

*/
router.post("/party-return", async (req, res) => {
const { yarn_lot_id, quantity } = req.body;

if (!yarn_lot_id || !quantity) {
return res.status(400).json({ error: "Missing fields" });
}

await pool.query(
`     INSERT INTO yarn_ledger
    (yarn_lot_id, transaction_type, quantity, remarks)
    VALUES ($1,'party_return',$2,'Returned to party')
    `,
[yarn_lot_id, quantity]
);

res.json({ message: "Returned to party" });
});

 /*

# SETTING CONSUMPTION

*/
router.post("/setting", async (req, res) => {
const { job_id, yarn_lot_id, quantity } = req.body;

if (!job_id || !yarn_lot_id || !quantity) {
return res.status(400).json({ error: "Missing fields" });
}

await pool.query(
`     INSERT INTO yarn_ledger
    (yarn_lot_id, job_id, transaction_type, quantity, remarks)
    VALUES ($1,$2,'setting',$3,'Machine setting consumption')
    `,
[yarn_lot_id, job_id, quantity]
);

res.json({ message: "Setting yarn recorded" });
});

 /*

# WASTE

*/
router.post("/waste", async (req, res) => {
const { job_id, yarn_lot_id, quantity } = req.body;

if (!job_id || !yarn_lot_id || !quantity) {
return res.status(400).json({ error: "Missing fields" });
}

await pool.query(
`     INSERT INTO yarn_ledger
    (yarn_lot_id, job_id, transaction_type, quantity, remarks)
    VALUES ($1,$2,'waste',$3,'Production waste')
    `,
[yarn_lot_id, job_id, quantity]
);

res.json({ message: "Waste recorded" });
});

 /*

# STOCK VIEW

*/
router.get("/stock", async (req, res) => {
const result = await pool.query(
  `   
    SELECT 
      yl.id AS yarn_lot_id,
      yl.lot_no,
      ym.yarn_name,
      p.name AS party_name,
      COALESCE(SUM(
        CASE
          WHEN y.transaction_type IN ('inward','return') THEN y.quantity
          WHEN y.transaction_type IN ('issue','waste','party_return','setting') THEN -y.quantity
        END
      ),0)::float AS balance
    FROM yarn_lot yl
    JOIN yarn_master ym ON yl.yarn_id = ym.id
    JOIN parties p ON yl.party_id = p.id
    LEFT JOIN yarn_ledger y ON yl.id = y.yarn_lot_id
    GROUP BY yl.id, yl.lot_no, ym.yarn_name, p.name
    ORDER BY yl.id DESC;
  `);

res.json(result.rows);
});

/* LEDGER REPORT (TALLY STYLE)            */

router.get("/ledger-report/:party_id", async (req, res) => {
const { party_id } = req.params;

try {
const result = await pool.query(
`
SELECT
y.created_at::date AS date,
yl.challan_no,
ym.yarn_name,
yl.lot_no,

    CASE WHEN y.transaction_type = 'inward' THEN y.quantity END AS inward,
    CASE WHEN y.transaction_type = 'issue' THEN y.quantity END AS issued,
    CASE WHEN y.transaction_type = 'return' THEN y.quantity END AS returned,
    CASE WHEN y.transaction_type = 'party_return' THEN y.quantity END AS party_return,
    CASE WHEN y.transaction_type = 'setting' THEN y.quantity END AS setting,
    CASE WHEN y.transaction_type = 'waste' THEN y.quantity END AS waste,

    SUM(
      CASE 
        WHEN y.transaction_type IN ('inward','return') THEN y.quantity
        WHEN y.transaction_type IN ('issue','waste','party_return','setting') THEN -y.quantity
      END
    ) OVER (
      PARTITION BY yl.id 
      ORDER BY y.created_at
    ) AS running_balance

  FROM yarn_ledger y
  JOIN yarn_lot yl ON y.yarn_lot_id = yl.id
  JOIN yarn_master ym ON yl.yarn_id = ym.id
  JOIN parties p ON yl.party_id = p.id

  WHERE p.id = $1

  ORDER BY y.created_at ASC;
  `,
  [party_id]
);

res.json(result.rows);


} catch (err) {
console.error("❌ LEDGER REPORT ERROR:", err);
res.status(500).json({ error: "Failed to generate ledger report" });
}
});


export default router;
