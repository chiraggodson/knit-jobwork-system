import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ================= HELPER: GET LOT BALANCE ================= */
async function getLotBalance(client, lotId) {
  const res = await client.query(
    `SELECT COALESCE(SUM(
      CASE 
        WHEN transaction_type IN ('inward','return') THEN quantity
        WHEN transaction_type IN ('issue','waste','party_return','setting') THEN -quantity
      END
    ),0) AS balance
    FROM yarn_ledger
    WHERE yarn_lot_id = $1`,
    [lotId]
  );

  return Number(res.rows[0].balance);
}

/* ================= HELPER: AUTO DEDUCT FIFO ================= */
async function autoDeductYarn(client, job_id, qty) {

  let remaining = qty;

  const lots = await client.query(
    `SELECT yl.id
     FROM yarn_lot yl
     JOIN job_orders j ON j.party_id = yl.party_id
     WHERE j.id = $1
     ORDER BY yl.id ASC`,
    [job_id]
  );

  for (const lot of lots.rows) {

    if (remaining <= 0) break;

    const balance = await getLotBalance(client, lot.id);

    if (balance <= 0) continue;

    const deduct = Math.min(balance, remaining);

    await client.query(
      `INSERT INTO yarn_ledger
       (yarn_lot_id, job_id, transaction_type, quantity, remarks)
       VALUES ($1,$2,'issue',$3,'Auto from production')`,
      [lot.id, job_id, deduct]
    );

    remaining -= deduct;
  }

  if (remaining > 0) {
    throw new Error("Not enough yarn stock (FIFO)");
  }
}

/* ================= ADD PRODUCTION ================= */
router.post("/", async (req, res) => {
  const { job_id, roll_no, quantity } = req.body;

  if (!job_id || !roll_no || !quantity) {
    return res.status(400).json({ error: "job_id, roll_no, quantity required" });
  }

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const jobCheck = await client.query(
      `SELECT id, status, order_quantity, machine_id
       FROM job_orders
       WHERE id = $1`,
      [job_id]
    );

    if (jobCheck.rowCount === 0) throw new Error("Job not found");

    const job = jobCheck.rows[0];

    if (job.status === "CLOSED") throw new Error("Job already closed");

    const prod = await client.query(
      `INSERT INTO fabric_production (job_id, roll_no, quantity)
       VALUES ($1, $2, $3)
       RETURNING id`,
      [job_id, roll_no, quantity]
    );

    const productionId = prod.rows[0].id;

    /* 🔥 AUTO DEDUCTION DISABLED (issue_mode removed) */

    const totalResult = await client.query(
      `SELECT COALESCE(SUM(quantity),0) AS produced
       FROM fabric_production
       WHERE job_id = $1`,
      [job_id]
    );

    const produced = Number(totalResult.rows[0].produced);
    const balance = job.order_quantity - produced;

    await client.query("COMMIT");

    res.json({ success: true, produced, balance });

  } catch (err) {
    await client.query("ROLLBACK");
    console.error("PRODUCTION ERROR:", err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

/* ================= BULK PRODUCTION ================= */
router.post("/bulk", async (req, res) => {

  const { job_id, weights } = req.body;

  if (!job_id || !weights || weights.length === 0) {
    return res.status(400).json({ error: "job_id and weights required" });
  }

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const jobRes = await client.query(
      `SELECT job_no, order_quantity, machine_id, status, party_id
       FROM job_orders
       WHERE id=$1`,
      [job_id]
    );

    if (jobRes.rowCount === 0) throw new Error("Job not found");

    const job = jobRes.rows[0];

    if (job.status === "CLOSED") throw new Error("Job already closed");

    let rollIndex = parseInt(
      (await client.query(`SELECT COUNT(*) FROM fabric_production WHERE job_id=$1`, [job_id]))
      .rows[0].count
    );

    for (const w of weights) {

      rollIndex++;

      const rollNo = `${job.job_no}-R${rollIndex.toString().padStart(3,'0')}`;

      const prod = await client.query(
        `INSERT INTO fabric_production (job_id, roll_no, quantity)
         VALUES ($1,$2,$3)
         RETURNING id`,
        [job_id, rollNo, w]
      );

      const productionId = prod.rows[0].id;

      /* 🔥 AUTO DEDUCTION DISABLED (issue_mode removed) */
    }

    const totalRes = await client.query(
      `SELECT COALESCE(SUM(quantity),0) AS produced
       FROM fabric_production
       WHERE job_id=$1`,
      [job_id]
    );

    const produced = Number(totalRes.rows[0].produced);
    const balance = job.order_quantity - produced;

    if (balance <= 0) {
      await client.query(`UPDATE job_orders SET status='CLOSED' WHERE id=$1`, [job_id]);
      await client.query(`UPDATE machines SET status='IDLE' WHERE id=$1`, [job.machine_id]);
    }

    await client.query("COMMIT");

    res.json({ success: true, produced, balance });

  } catch(err) {
    await client.query("ROLLBACK");
    console.error("BULK PRODUCTION ERROR:", err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

export default router;