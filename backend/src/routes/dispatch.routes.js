import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ================= DISPATCH ROLLS ================= */

router.post("/", async (req, res) => {

  const { job_id, rolls } = req.body;

  if (!job_id || !rolls || rolls.length === 0) {
    return res.status(400).json({ error: "job_id and rolls required" });
  }

  const client = await pool.connect();

  try {

    await client.query("BEGIN");

    /* 1️⃣ Insert dispatch records */

    for (const r of rolls) {

      await client.query(
        `
        INSERT INTO fabric_dispatch
        (job_id, roll_no, quantity)
        VALUES ($1,$2,$3)
        `,
        [job_id, r.roll_no, r.quantity]
      );

    }

    /* 2️⃣ Check remaining rolls */

    const remaining = await client.query(
      `
      SELECT COUNT(*) 
      FROM fabric_production fp
      WHERE fp.job_id = $1
      AND fp.roll_no NOT IN (
        SELECT roll_no
        FROM fabric_dispatch
        WHERE job_id = $1
      )
      `,
      [job_id]
    );

    const remainingCount = Number(remaining.rows[0].count);

    /* 2️⃣ Check if job should close */

const check = await client.query(
`
SELECT
  j.order_quantity,

  COALESCE((
    SELECT SUM(quantity)
    FROM fabric_dispatch
    WHERE job_id = j.id
  ),0) AS dispatched

FROM job_orders j
WHERE j.id = $1
`,
[job_id]
);

const job = check.rows[0];

const orderQty = Number(job.order_quantity);
const dispatched = Number(job.dispatched);

/* 3️⃣ Auto close if dispatched >= order */

if (dispatched >= orderQty) {

  const machine = await client.query(
    `SELECT machine_id FROM job_orders WHERE id=$1`,
    [job_id]
  );

  const machineId = machine.rows[0].machine_id;

  await client.query(
    `UPDATE job_orders SET status='CLOSED' WHERE id=$1`,
    [job_id]
  );

  await client.query(
    `UPDATE machines SET status='IDLE' WHERE id=$1`,
    [machineId]
  );

}

    await client.query("COMMIT");

    res.json({
      success: true,
      message: "Dispatch successful"
    });

  } catch (err) {

    await client.query("ROLLBACK");

    console.error("DISPATCH ERROR:", err);

    res.status(500).json({
      error: "Dispatch failed"
    });

  } finally {

    client.release();

  }

});
/* ================= GET ROLLS FOR DISPATCH ================= */

router.get("/job/:job_id", async (req, res) => {

  const { job_id } = req.params;

  try {

    const result = await pool.query(
      `
      SELECT roll_no, quantity
      FROM fabric_production
      WHERE job_id = $1
      AND roll_no NOT IN (
        SELECT roll_no
        FROM fabric_dispatch
        WHERE job_id = $1
      )
      ORDER BY produced_at
      `,
      [job_id]
    );

    res.json(result.rows);

  } catch (err) {

    console.error(err);

    res.status(500).json({
      error: "Failed to load rolls"
    });

  }

});
export default router;