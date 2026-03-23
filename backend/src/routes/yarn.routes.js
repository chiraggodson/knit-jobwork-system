import express from "express";
import { pool } from "../db.js";

const router = express.Router();
/* ============================================================
   GET ALL YARNS (FULL DATA FOR PRODUCTS SCREEN)
============================================================ */
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, yarn_name, yarn_count, yarn_type
      FROM yarn_master
      ORDER BY yarn_name ASC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("❌ GET YARN ERROR:", err);
    res.status(500).json({ error: "Failed to load yarns" });
  }
});

/* ============================================================
   GET ALL YARNS (FOR DROPDOWN / PRODUCTS SCREEN)
============================================================ */
router.post("/", async (req, res) => {
  try {
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
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to add yarn" });
  }
});



/* ============================================================
   ADD YARN INWARD (ERP STYLE)
============================================================ */
router.post("/inward", async (req, res) => {
  try {
    const { party_id, yarn_id, lot_no, challan_no, inward_date, quantity } =
      req.body;

    if (!party_id || !yarn_id || !lot_no || !quantity) {
      return res.status(400).json({ error: "Missing required fields" });
    }

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
      VALUES ($1,'INWARD',$2,'Yarn inward entry')
      `,
      [lotId, quantity]
    );

    await pool.query("COMMIT");

    res.json({ message: "Yarn inward added (ERP style)" });
  } catch (err) {
    await pool.query("ROLLBACK");
    console.error("❌ INWARD ERROR:", err);
    res.status(500).json({ error: "Failed to add inward" });
  }
});

/* ============================================================
   VIEW LOT STOCK (LIVE BALANCE FROM LEDGER)
============================================================ */
router.get("/stock", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        yl.id AS yarn_lot_id,
        yl.lot_no,
        yl.quantity_received,
        ym.yarn_name,
        p.name AS party_name,
        COALESCE(SUM(
          CASE
            WHEN y.transaction_type = 'INWARD' THEN y.quantity
            WHEN y.transaction_type = 'RETURN' THEN y.quantity
            WHEN y.transaction_type = 'ISSUE' THEN -y.quantity
            WHEN y.transaction_type = 'WASTE' THEN -y.quantity
            WHEN y.transaction_type = 'PARTY_RETURN' THEN -y.quantity
          END
        ),0)::float AS balance
      FROM yarn_lot yl
      JOIN yarn_master ym ON yl.yarn_id = ym.id
      JOIN parties p ON yl.party_id = p.id
      LEFT JOIN yarn_ledger y ON yl.id = y.yarn_lot_id
      GROUP BY yl.id, yl.lot_no, yl.quantity_received, ym.yarn_name, p.name
      ORDER BY yl.id DESC;
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("❌ STOCK ERROR:", err);
    res.status(500).json({ error: "Failed to fetch stock" });
  }
});

/* ============================================================
   ISSUE YARN (ERP LEDGER ENTRY)
============================================================ */
router.post("/issue", async (req, res) => {
  try {
    const { job_id, yarn_lot_id, quantity } = req.body;

    if (!job_id || !yarn_lot_id || !quantity || quantity <= 0) {
      return res.status(400).json({ error: "Invalid input" });
    }

    await pool.query("BEGIN");

    const stock = await pool.query(
      `
      SELECT 
        COALESCE(SUM(
          CASE
            WHEN transaction_type = 'INWARD' THEN quantity
            WHEN transaction_type = 'RETURN' THEN quantity
            WHEN transaction_type = 'ISSUE' THEN -quantity
            WHEN transaction_type = 'WASTE' THEN -quantity
            WHEN transaction_type = 'PARTY_RETURN' THEN -quantity
          END
        ),0) AS balance
      FROM yarn_ledger
      WHERE yarn_lot_id = $1
      `,
      [yarn_lot_id]
    );

    const balance = Number(stock.rows[0].balance);

    if (balance < quantity) {
      await pool.query("ROLLBACK");
      return res.status(400).json({ error: "Insufficient yarn balance" });
    }

    await pool.query(
      `
      INSERT INTO yarn_ledger
      (yarn_lot_id, job_id, transaction_type, quantity, remarks)
      VALUES ($1,$2,'ISSUE',$3,'Issued to job')
      `,
      [yarn_lot_id, job_id, quantity]
    );

   

    await pool.query("COMMIT");

    res.json({ message: "Yarn issued (ERP style)" });
  } catch (err) {
    await pool.query("ROLLBACK");
    console.error("❌ ISSUE ERROR:", err);
    res.status(500).json({ error: "Yarn issue failed" });
  }
});
/* ============================================================
   PARTY YARN SUMMARY (Ledger View)
============================================================ */
router.get("/party-ledger", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
  p.id AS party_id,
  p.name AS party_name,

  COALESCE(SUM(
    CASE WHEN y.transaction_type = 'INWARD' THEN y.quantity END
  ),0)::float AS yarn_inward,

  COALESCE(SUM(
    CASE WHEN y.transaction_type = 'ISSUE' THEN y.quantity END
  ),0)::float AS yarn_issued,

  COALESCE(SUM(
    CASE WHEN y.transaction_type = 'RETURN' THEN y.quantity END
  ),0)::float AS yarn_returned,

  COALESCE(SUM(
    CASE
      WHEN y.transaction_type IN ('INWARD','RETURN') THEN y.quantity
      WHEN y.transaction_type IN ('ISSUE','WASTE','PARTY_RETURN') THEN -y.quantity
    END
  ),0)::float AS balance

FROM parties p
LEFT JOIN yarn_lot yl ON yl.party_id = p.id
LEFT JOIN yarn_ledger y ON y.yarn_lot_id = yl.id

GROUP BY p.id, p.name
ORDER BY p.name ASC;
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("❌ PARTY LEDGER ERROR:", err);
    res.status(500).json({ error: "Failed to load party ledger" });
  }
});

/* ============================================================
   ADD WASTE (LEDGER ENTRY)
============================================================ */
router.post("/waste", async (req, res) => {
  try {
    const { job_id, yarn_lot_id, quantity } = req.body;

    if (!job_id || !yarn_lot_id || !quantity) {
      return res.status(400).json({ error: "Missing fields" });
    }

    await pool.query(
      `
      INSERT INTO yarn_ledger
      (yarn_lot_id, job_id, transaction_type, quantity, remarks)
      VALUES ($1,$2,'WASTE',$3,'Production waste')
      `,
      [yarn_lot_id, job_id, quantity]
    );

    res.json({ message: "Waste recorded" });
  } catch (err) {
    console.error("❌ WASTE ERROR:", err);
    res.status(500).json({ error: "Waste failed" });
  }
});

/* ============================================================
   YARN MASTER LIST (Simple ID + NAME)
============================================================ */
router.get("/master", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, yarn_name
      FROM yarn_master
      ORDER BY yarn_name
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("❌ YARN MASTER ERROR:", err);
    res.status(500).json({ error: "Failed to load yarn master" });
  }
});

/* ============================================================
   STOCK BY PARTY
============================================================ */
router.get("/stock/:party_id", async (req, res) => {
  try {
    const { party_id } = req.params;

    const result = await pool.query(`
      SELECT 
        yl.id AS yarn_lot_id,
        yl.lot_no,
        ym.yarn_name,
        p.name AS party_name,
        COALESCE(SUM(
          CASE
            WHEN y.transaction_type = 'INWARD' THEN y.quantity
            WHEN y.transaction_type = 'RETURN' THEN y.quantity
            WHEN y.transaction_type = 'ISSUE' THEN -y.quantity
            WHEN y.transaction_type = 'WASTE' THEN -y.quantity
            WHEN y.transaction_type = 'PARTY_RETURN' THEN -y.quantity
          END
        ),0)::float AS balance
      FROM yarn_lot yl
      JOIN yarn_master ym ON yl.yarn_id = ym.id
      JOIN parties p ON yl.party_id = p.id
      LEFT JOIN yarn_ledger y ON yl.id = y.yarn_lot_id
      WHERE yl.party_id = $1
      GROUP BY yl.id, yl.lot_no, ym.yarn_name, p.name
      HAVING COALESCE(SUM(
          CASE
            WHEN y.transaction_type = 'INWARD' THEN y.quantity
            WHEN y.transaction_type = 'RETURN' THEN y.quantity
            WHEN y.transaction_type = 'ISSUE' THEN -y.quantity
            WHEN y.transaction_type = 'WASTE' THEN -y.quantity
            WHEN y.transaction_type = 'PARTY_RETURN' THEN -y.quantity
          END
        ),0) > 0
      ORDER BY yl.id DESC;
    `, [party_id]);

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Stock load failed" });
  }
});
router.post("/yarn/setting", async (req, res) => {
  const { job_id, yarn_lot_id, quantity } = req.body;

  try {
    await pool.query(`
      INSERT INTO yarn_ledger 
      (job_id, yarn_lot_id, quantity, transaction_type)
      VALUES ($1, $2, $3, 'SETTING')
    `, [job_id, yarn_lot_id, quantity]);

    res.json({ success: true });

  } catch (err) {
    console.error("SETTING ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});
export default router;
