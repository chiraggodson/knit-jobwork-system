import express from "express";
import {pool} from "../db.js";

const router = express.Router();

/* ================= CREATE DISPATCH ================= */

router.post("/create", async (req, res) => {
const client = await pool.connect();

try {
const {
job_id,
challan_no,
date,
party_po,
design_no,
fabric,
lot_no,
color,
rolls
} = req.body;


if (!job_id || !rolls || rolls.length === 0) {
  return res.status(400).json({
    error: "Job ID and rolls are required"
  });
}

await client.query("BEGIN");

/* ================= VALIDATE ROLLS ================= */

const rollNos = rolls.map(r => r.roll_no);

const existing = await client.query(
  `SELECT roll_no FROM fabric_dispatch WHERE roll_no = ANY($1)`,
  [rollNos]
);

if (existing.rows.length > 0) {
  await client.query("ROLLBACK");
  return res.status(400).json({
    error: "Some rolls already dispatched",
    rolls: existing.rows
  });
}

/* ================= TOTAL ================= */

const total_rolls = rolls.length;

const total_weight = rolls.reduce((sum, r) => {
  return sum + parseFloat(r.quantity || 0);
}, 0);

/* ================= INSERT MASTER ================= */

const masterRes = await client.query(
  `INSERT INTO fabric_dispatch_master
  (job_id, challan_no, dispatch_date, party_po, design_no, fabric, lot_no, color, total_rolls, total_weight)
  VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
  RETURNING id`,
  [
    job_id,
    challan_no,
    date,
    party_po,
    design_no,
    fabric,
    lot_no,
    color,
    total_rolls,
    total_weight
  ]
);

const dispatch_id = masterRes.rows[0].id;

/* ================= INSERT ROLLS ================= */

for (const r of rolls) {
  await client.query(
    `INSERT INTO fabric_dispatch
    (job_id, roll_no, quantity, dispatch_id)
    VALUES ($1,$2,$3,$4)`,
    [job_id, r.roll_no, r.quantity, dispatch_id]
  );
}

/* ================= UPDATE JOB ================= */

const totalDispatchRes = await client.query(
  `SELECT COALESCE(SUM(quantity),0) as total
   FROM fabric_dispatch
   WHERE job_id = $1`,
  [job_id]
);

const dispatchedQty = parseFloat(totalDispatchRes.rows[0].total);

const jobRes = await client.query(
  `SELECT order_quantity FROM job_orders WHERE id = $1`,
  [job_id]
);

const orderQty = parseFloat(jobRes.rows[0].order_quantity);

let status = "OPEN";
if (dispatchedQty >= orderQty) {
  status = "CLOSED";
}

await client.query(
  `UPDATE job_orders
   SET dispatched_quantity = $1,
       status = $2
   WHERE id = $3`,
  [dispatchedQty, status, job_id]
);

await client.query("COMMIT");

res.json({
  message: "Dispatch created successfully",
  dispatch_id
});


} catch (err) {


await client.query("ROLLBACK");

console.error(err);

res.status(500).json({
  error: "Dispatch failed",
  details: err.message
});


} finally {
client.release();
}
});

/* ================= GET DISPATCH LIST ================= */


router.get("/", async (req, res) => {
try {
  const { id } = req.params;


const result = await pool.query(`
  SELECT 
    d.id,
    d.challan_no,
    TO_CHAR(d.dispatch_date, 'YYYY-MM-DD') as date,
    j.party_id as party,
    d.fabric,
    d.lot_no,
    d.color,
    d.total_rolls,
    d.total_weight
  FROM fabric_dispatch_master d
  LEFT JOIN job_orders j ON j.id = d.job_id
  ORDER BY d.id DESC
`);

res.json(result.rows);


} catch (err) {


console.error(err);

res.status(500).json({
  error: "Failed to fetch dispatch list"
});


}
});


export default router;
