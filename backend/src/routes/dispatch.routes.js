import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ================= DISPATCH ROLLS ================= */

router.post("/", async (req, res) => {

  const { job_id, rolls, challan_no, dispatch_date } = req.body;

  if (!job_id || !rolls || rolls.length === 0) {
    return res.status(400).json({ error: "job_id and rolls required" });
  }

  if (!challan_no) {
    return res.status(400).json({ error: "challan_no required" });
  }

  const client = await pool.connect();

  try {

    await client.query("BEGIN");

    /* 1️⃣ Validate job */
    const jobRes = await client.query(
      `SELECT id, order_quantity, machine_id FROM job_orders WHERE id=$1`,
      [job_id]
    );

    if (jobRes.rowCount === 0) {
      throw new Error("Job not found");
    }

    const job = jobRes.rows[0];

    /* 2️⃣ Validate rolls exist + not already dispatched */

    for (const r of rolls) {

      const check = await client.query(
        `
        SELECT 1 FROM fabric_dispatch
        WHERE job_id=$1 AND roll_no=$2
        `,
        [job_id, r.roll_no]
      );

      if (check.rowCount > 0) {
        throw new Error(`Roll already dispatched: ${r.roll_no}`);
      }

      const exists = await client.query(
        `
        SELECT 1 FROM fabric_production
        WHERE job_id=$1 AND roll_no=$2
        `,
        [job_id, r.roll_no]
      );

      if (exists.rowCount === 0) {
        throw new Error(`Invalid roll: ${r.roll_no}`);
      }
    }

    /* 3️⃣ Insert dispatch */

    for (const r of rolls) {

      await client.query(
        `
        INSERT INTO fabric_dispatch
        (job_id, roll_no, quantity, challan_no, dispatch_date)
        VALUES ($1,$2,$3,$4,$5)
        `,
        [
          job_id,
          r.roll_no,
          r.quantity,
          challan_no,
          dispatch_date || new Date()
        ]
      );

      /* OPTIONAL: mark production as dispatched */
      await client.query(
        `
        UPDATE fabric_production
        SET status = 'DISPATCHED'
        WHERE job_id=$1 AND roll_no=$2
        `,
        [job_id, r.roll_no]
      );
    }

    /* 4️⃣ Calculate totals */

    const totalRes = await client.query(
      `
      SELECT COALESCE(SUM(quantity),0) AS dispatched
      FROM fabric_dispatch
      WHERE job_id=$1
      `,
      [job_id]
    );

    const dispatched = Number(totalRes.rows[0].dispatched);
    const orderQty = Number(job.order_quantity);

    /* 5️⃣ Auto close job */

    if (dispatched >= orderQty) {

      await client.query(
        `UPDATE job_orders SET status='CLOSED' WHERE id=$1`,
        [job_id]
      );

      await client.query(
        `UPDATE machines SET status='IDLE' WHERE id=$1`,
        [job.machine_id]
      );
    }

    await client.query("COMMIT");

    res.json({
      success: true,
      dispatched,
      message: "Dispatch successful"
    });

  } catch (err) {

    await client.query("ROLLBACK");

    console.error("DISPATCH ERROR:", err);

    res.status(500).json({
      error: err.message
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

router.get("/dispatch/jobs", async (req, res) => {

  const result = await pool.query(`
    SELECT
      j.id,
      j.job_no,
      p.name AS party_name,

      COALESCE((
        SELECT SUM(quantity)
        FROM fabric_production fp
        WHERE fp.job_id = j.id
      ),0) AS produced,

      COALESCE((
        SELECT SUM(quantity)
        FROM fabric_dispatch fd
        WHERE fd.job_id = j.id
      ),0) AS dispatched

    FROM job_orders j
    JOIN parties p ON j.party_id = p.id

    ORDER BY j.id DESC
  `);

  res.json(result.rows);

});


export default router;