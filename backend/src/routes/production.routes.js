import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ================= ADD PRODUCTION ================= */
router.post("/", async (req, res) => {
  const { job_id, roll_no, quantity } = req.body;

  if (!job_id || !roll_no || !quantity) {
    return res.status(400).json({ error: "job_id, roll_no, quantity required" });
  }

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    /* 1️⃣ Check job exists */
    const jobCheck = await client.query(
      `SELECT id, status, order_quantity, machine_id
       FROM job_orders
       WHERE id = $1`,
      [job_id]
    );

    if (jobCheck.rowCount === 0) {
      throw new Error("Job not found");
    }

    if (jobCheck.rows[0].status === "CLOSED") {
      throw new Error("Job already closed");
    }

    const orderQty = Number(jobCheck.rows[0].order_quantity);
    const machineId = jobCheck.rows[0].machine_id;

    /* 2️⃣ Insert production */
    await client.query(
      `INSERT INTO fabric_production (job_id, roll_no, quantity)
       VALUES ($1, $2, $3)`,
      [job_id, roll_no, quantity]
    );

    /* 3️⃣ Calculate new total production */
    const totalResult = await client.query(
      `SELECT COALESCE(SUM(quantity),0) AS produced
       FROM fabric_production
       WHERE job_id = $1`,
      [job_id]
    );

    const produced = Number(totalResult.rows[0].produced);
    const balance = orderQty - produced;

    await client.query("COMMIT");

    res.json({ success: true });

  } catch (err) {
    await client.query("ROLLBACK");
    console.error("PRODUCTION ERROR:", err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});


/* ================= VIEW PRODUCTION ================= */
router.get("/:job_id", async (req, res) => {
  const { job_id } = req.params;

  try {
    const result = await pool.query(
      `SELECT id, roll_no, quantity, produced_at
       FROM fabric_production
       WHERE job_id = $1
       ORDER BY produced_at`,
      [job_id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("VIEW PRODUCTION ERROR:", err);
    res.status(500).json({ error: "Failed to load production" });
  }
});

router.post("/bulk", async (req, res) => {

  const { job_id, weights } = req.body;

  if (!job_id || !weights || weights.length === 0) {
    return res.status(400).json({
      error: "job_id and weights required"
    });
  }

  const client = await pool.connect();

  try {

    await client.query("BEGIN");

    /* 1️⃣ Get job info */

    const jobRes = await client.query(
      `SELECT job_no, order_quantity, machine_id, status
       FROM job_orders
       WHERE id=$1`,
      [job_id]
    );

    if (jobRes.rowCount === 0) {
      throw new Error("Job not found");
    }

    const job = jobRes.rows[0];

    if (job.status === "CLOSED") {
      throw new Error("Job already closed");
    }

    const jobNo = job.job_no;
    const orderQty = Number(job.order_quantity);
    const machineId = job.machine_id;

    /* 2️⃣ Get current roll count */

    const countRes = await client.query(
      `SELECT COUNT(*) FROM fabric_production WHERE job_id=$1`,
      [job_id]
    );

    let rollIndex = parseInt(countRes.rows[0].count);

    /* 3️⃣ Insert all rolls */

    for (const w of weights) {

      rollIndex++;

      const rollNo =
        `${jobNo}-R${rollIndex.toString().padStart(3,'0')}`;

      await client.query(
        `INSERT INTO fabric_production
        (job_id, roll_no, quantity)
        VALUES ($1,$2,$3)`,
        [job_id, rollNo, w]
      );
    }

    /* 4️⃣ Recalculate production */

    const totalRes = await client.query(
      `SELECT COALESCE(SUM(quantity),0) AS produced
       FROM fabric_production
       WHERE job_id=$1`,
      [job_id]
    );

    const produced = Number(totalRes.rows[0].produced);
    const balance = orderQty - produced;

    /* 5️⃣ Auto close job */

    if (balance <= 0) {

      await client.query(
        `UPDATE job_orders
         SET status='CLOSED'
         WHERE id=$1`,
        [job_id]
      );

      await client.query(
        `UPDATE machines
         SET status='IDLE'
         WHERE id=$1`,
        [machineId]
      );
    }

    await client.query("COMMIT");

    res.json({
      success: true,
      produced,
      balance
    });

  } catch(err) {

    await client.query("ROLLBACK");

    console.error("BULK PRODUCTION ERROR:", err);

    res.status(500).json({
      error: err.message
    });

  } finally {

    client.release();

  }

});

export default router;