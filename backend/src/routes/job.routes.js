console.log("✅ job.routes.js LOADED");


import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ================= CREATE JOB ================= */
import multer from "multer";
import path from "path";

const storage = multer.diskStorage({

  destination: function (req, file, cb) {
    cb(null, "uploads/");
  },

  filename: function (req, file, cb) {
  const ext = path.extname(file.originalname);
  const uniqueName = `FABRIC_${Date.now()}${ext}`;
  cb(null, uniqueName);
}
});

const upload = multer({ storage });

router.post("/",  upload.single("image"), async (req, res) => {
 
  
  let { party_id, machine_ids, fabric_id, gsm, order_quantity, yarns } = req.body;
  const fabric_image = req.file ? req.file.filename : null;

/* 🔹 Parse machine_ids if sent as string */
if (typeof machine_ids === "string") {
  machine_ids = JSON.parse(machine_ids);
}

/* 🔹 Parse yarns if sent as string */
if (typeof yarns === "string") {
  yarns = JSON.parse(yarns);
}

  const client = await pool.connect();

  try {
    await client.query("BEGIN");
if (!Array.isArray(machine_ids) || machine_ids.length === 0) {
  throw new Error("Select at least one machine");
}

    /* 1️⃣ Get highest job number ONCE */
    const lastJobResult = await client.query(`
      SELECT job_no
      FROM job_orders
      ORDER BY id DESC
      LIMIT 1
    `);

    let nextNumber = 1;

    if (lastJobResult.rows.length > 0) {
      const lastJob = lastJobResult.rows[0].job_no;
      const numericPart = lastJob.replace("BBJO", "");
      nextNumber = parseInt(numericPart, 10) + 1;
    }

    const splitQty = order_quantity / machine_ids.length;
    const createdJobs = [];

    /* 2️⃣ Loop machines SAFELY */
    for (const machineId of machine_ids) {

      const jobNo = `BBJO${String(nextNumber).padStart(3, "0")}`;
      nextNumber++;

      

      const jobInsert = await client.query(`
        INSERT INTO job_orders
        (job_no, party_id, machine_id, fabric_id, gsm, order_quantity, status, fabric_image)
        VALUES ($1,$2,$3,$4,$5,$6,'OPEN',$7)
        RETURNING id
      `, [
        jobNo,
        party_id,
        machineId,
        fabric_id,
        gsm,
        splitQty,
        fabric_image
      ]);

      const jobId = jobInsert.rows[0].id;

      /* ✅ Set machine RUNNING inside loop */
      await client.query(
        `UPDATE machines SET status='RUNNING' WHERE id=$1`,
        [machineId]
      );

      /* 3️⃣ Insert yarns (if any) */
      if (yarns && yarns.length > 0) {
        for (const yarn of yarns) {
          await client.query(`
            INSERT INTO job_yarns (job_id, yarn_id, percentage)
            VALUES ($1,$2,$3)
          `, [
            jobId,
            yarn.yarn_id,
            yarn.percentage || null
          ]);
        }
      }

      createdJobs.push(jobNo);
    }

    await client.query("COMMIT");

    res.json({
      message: "Jobs created successfully",
      jobs: createdJobs
    });

  } catch (err) {
    await client.query("ROLLBACK");
    console.error("❌ CREATE JOB ERROR:", err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});


/* ================= JOB LIST (SUMMARY PAGE) ================= */
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        j.id,
        j.job_no,
        j.fabric_id,
        f.name AS fabric_name,
        j.party_id,
        p.name AS party_name,
        j.machine_id,
        m.machine_no,
        j.gsm,
        j.order_quantity,
        j.status,
        j.created_at,

        /* 🔹 Yarn Summary (FIXED TABLE NAME) */
        (
          SELECT STRING_AGG(y.yarn_name, ', ')
          FROM job_yarns jy
          JOIN yarn_master y ON y.id = jy.yarn_id
          WHERE jy.job_id = j.id
        ) AS yarns_used,

        COALESCE((
          SELECT SUM(quantity)
          FROM fabric_production
          WHERE job_id = j.id
        ),0)::float AS actual_production,

        COALESCE((
          SELECT AVG(quantity)
          FROM fabric_production
          WHERE job_id = j.id
        ),0)::float AS avg_roll_size,

        (j.order_quantity - COALESCE((
          SELECT SUM(quantity)
          FROM fabric_production
          WHERE job_id = j.id
        ),0))::float AS remaining_quantity

      FROM job_orders j
      LEFT JOIN parties p ON p.id = j.party_id
      LEFT JOIN fabrics f ON f.id = j.fabric_id
      LEFT JOIN machines m ON m.id = j.machine_id

      ORDER BY j.created_at DESC
    `);

    res.json(result.rows);

  } catch (err) {
    console.error("❌ GET JOBS ERROR:", err);
    res.status(500).json({ error: "Failed to load jobs" });
  }
});



/* ================= CLOSE JOB ================= */
router.put("/close/:job_no",   async (req, res) => {
  try {
    const { job_no } = req.params;

    const job = await pool.query(
      `SELECT id, machine_id FROM job_orders WHERE job_no = $1`,
      [job_no]
    );

    if (job.rowCount === 0) {
      return res.status(404).json({ error: "Job not found" });
    }

    const jobId = job.rows[0].id;
    const machineId = job.rows[0].machine_id;

    await pool.query(
      `UPDATE job_orders SET status='CLOSED' WHERE id=$1`,
      [jobId]
    );

    await pool.query(
      `UPDATE machines SET status='IDLE' WHERE id=$1`,
      [machineId]
    );

    res.json({ success: true });

  } catch (err) {
    console.error("❌ CLOSE JOB ERROR:", err);
    res.status(500).json({ error: "Failed to close job" });
  }
});

/* ================= JOB YARN HISTORY ================= */
router.get("/:job_no/yarn-history", async (req, res) => {
  try {
    const { job_no } = req.params;

    const result = await pool.query(`
      SELECT
        y.transaction_type,
        y.quantity,
        y.created_at,
        yl.lot_no,
        ym.yarn_name,
        y.remarks
      FROM yarn_ledger y
      JOIN yarn_lot yl ON y.yarn_lot_id = yl.id
      JOIN yarn_master ym ON yl.yarn_id = ym.id
      JOIN job_orders j ON y.job_id = j.id
      WHERE j.job_no = $1
      ORDER BY y.created_at DESC
    `, [job_no]);

    res.json(result.rows);

  } catch (err) {
    console.error("❌ YARN HISTORY ERROR:", err);
    res.status(500).json({ error: "Failed to load yarn history" });
  }
});

/* ================= JOB PRODUCTION HISTORY ================= */
router.get("/:job_no/production-history", async (req, res) => {
  try {
    const { job_no } = req.params;

    const result = await pool.query(`
      SELECT
        roll_no,
        quantity,
        created_at
      FROM fabric_production fp
      JOIN job_orders j ON fp.job_id = j.id
      WHERE j.job_no = $1
      ORDER BY created_at DESC
    `, [job_no]);

    res.json(result.rows);

  } catch (err) {
    console.error("❌ PRODUCTION HISTORY ERROR:", err);
    res.status(500).json({ error: "Failed to load production history" });
  }
});

/* ================= JOB DISPATCH HISTORY ================= */

router.get("/:job_no/dispatch-history",  async (req, res) => {

  try {

    const { job_no } = req.params;

    const result = await pool.query(`
      SELECT
        roll_no,
        quantity,
        dispatched_at
      FROM fabric_dispatch fd
      JOIN job_orders j ON fd.job_id = j.id
      WHERE j.job_no = $1
      ORDER BY dispatched_at DESC
    `, [job_no]);

    res.json(result.rows);

  } catch (err) {

    console.error("❌ DISPATCH HISTORY ERROR:", err);

    res.status(500).json({
      error: "Failed to load dispatch history"
    });

  }

});

router.get("/details/:id", async (req, res) => {

  try {

    const id = parseInt(req.params.id);

    const job = await pool.query(
      `SELECT * FROM job_orders WHERE id=$1`,
      [id]
    );

    if (job.rowCount === 0) {
      return res.status(404).json({ error: "Job not found" });
    }

    const machines = await pool.query(
      `SELECT machine_id FROM job_machines WHERE job_id=$1`,
      [id]
    );

    const yarns = await pool.query(
      `SELECT yarn_id FROM job_yarns WHERE job_id=$1`,
      [id]
    );

    let machineList = machines.rows.map(m => m.machine_id);

    /* fallback if job_machines empty */
    if (machineList.length === 0 && job.rows[0].machine_id) {
      machineList = [job.rows[0].machine_id];
    }

    res.json({
      ...job.rows[0],
      machines: machineList,
      yarns: yarns.rows
    });

  } catch (err) {

    console.error("❌ JOB DETAILS ERROR:", err);
    res.status(500).json({ error: "Failed to load job details" });

  }

});


/* ================= SINGLE JOB DETAIL ================= */
router.get("/:job_no", async (req, res) => {
  try {
    const { job_no } = req.params;

    const result = await pool.query(`
      SELECT
        j.*,
        p.name AS party_name,
        m.machine_no,
        f.name AS fabric_name,

        COALESCE((
          SELECT SUM(quantity)
          FROM yarn_ledger
          WHERE job_id = j.id AND transaction_type = 'issue'
        ),0)::float AS yarn_issued,

        COALESCE((
          SELECT SUM(quantity)
          FROM yarn_ledger
          WHERE job_id = j.id AND transaction_type = 'return'
        ),0)::float AS yarn_returned,

        COALESCE((
          SELECT SUM(quantity)
          FROM yarn_ledger
          WHERE job_id = j.id AND transaction_type = 'waste'
        ),0)::float AS waste,

        COALESCE((
          SELECT SUM(quantity)
          FROM fabric_production
          WHERE job_id = j.id
        ),0)::float AS fabric_produced,

        COALESCE((
          SELECT SUM(quantity)
          FROM fabric_dispatch
          WHERE job_id = j.id
        ),0)::float AS fabric_dispatched

      FROM job_orders j
      LEFT JOIN parties p ON p.id = j.party_id
      LEFT JOIN machines m ON m.id = j.machine_id
      LEFT JOIN fabrics f ON f.id = j.fabric_id
      WHERE j.job_no = $1
    `, [job_no]);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Job not found" });
    }

    const job = result.rows[0];

    /* 🔥 CORRECT YARN QUERY */
    const yarns = await pool.query(`
      SELECT 
        ym.yarn_name,
        jy.percentage AS mix_percent,

        COALESCE(SUM(
          CASE 
          WHEN yl.transaction_type = 'issue' THEN yl.quantity
          WHEN yl.transaction_type = 'return' THEN -yl.quantity
          WHEN yl.transaction_type = 'setting' THEN -yl.quantity  -- 🔥 important
          ELSE 0
        END
        ), 0) AS issued

      FROM job_yarns jy
      JOIN yarn_master ym ON ym.id = jy.yarn_id

      LEFT JOIN yarn_lot ylot ON ylot.yarn_id = jy.yarn_id
      LEFT JOIN yarn_ledger yl 
        ON yl.yarn_lot_id = ylot.id
        AND yl.job_id = jy.job_id

      WHERE jy.job_id = $1
      GROUP BY ym.yarn_name, jy.percentage
    `, [job.id]);

    job.yarns = yarns.rows;

    res.json(job);

  } catch (err) {
    console.error("❌ JOB DETAIL ERROR:", err);
    res.status(500).json({ error: "Failed to load job detail" });
  }
});


/* ================= CHANGE MACHINE ================= */

router.put("/change-machine/:job_id", async (req, res) => {

  const jobId = req.params.job_id;
  const { new_machine_id } = req.body;

  const client = await pool.connect();

  try {

    await client.query("BEGIN");

    const job = await client.query(
      `SELECT machine_id FROM job_orders WHERE id=$1`,
      [jobId]
    );

    if (job.rowCount === 0) {
      throw new Error("Job not found");
    }

    const oldMachine = job.rows[0].machine_id;

    /* update job */
    await client.query(
      `UPDATE job_orders SET machine_id=$1 WHERE id=$2`,
      [new_machine_id, jobId]
    );

    /* machine status */
    await client.query(
      `UPDATE machines SET status='IDLE' WHERE id=$1`,
      [oldMachine]
    );

    await client.query(
      `UPDATE machines SET status='RUNNING' WHERE id=$1`,
      [new_machine_id]
    );

    await client.query("COMMIT");
    res.json({
      success: true
    });

  } catch (err) {
    await client.query("ROLLBACK");
    console.error("❌ CHANGE MACHINE ERROR:", err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});
/* ================= Yarn Issues to machine ================= */
router.get("/:job_id/issued-yarns", async (req, res) => {
  const { job_id } = req.params;

  try {
    const result = await pool.query(
      `
      SELECT 
  yl.id AS yarn_lot_id,
  yl.lot_no,
  ym.yarn_name,

  jo.order_quantity -
  COALESCE(fp.total_produced, 0) AS balance

FROM job_orders jo

LEFT JOIN (
  SELECT job_id, SUM(quantity) AS total_produced
  FROM fabric_production
  GROUP BY job_id
) fp ON fp.job_id = jo.id

JOIN job_yarns jy ON jy.job_id = jo.id
JOIN yarn_master ym ON ym.id = jy.yarn_id
JOIN yarn_lot yl ON yl.yarn_id = jy.yarn_id

WHERE jo.id = $1
      `,
      [job_id]
    );

    res.json(result.rows);

  } catch (err) {
    console.error("ISSUED YARN FETCH ERROR:", err);
    res.status(500).json({ error: "Failed to load yarns" });
  }
});

/* ================= UPDATE JOB ================= */

router.put("/:id", async (req, res) => {

  const jobId = req.params.id;

  const {
    party_id,
    machine_ids,
    fabric_id,
    gsm,
    order_quantity,
    yarns
  } = req.body;

  const client = await pool.connect();

  try {

    await client.query("BEGIN");

    if (!party_id || !fabric_id || !gsm || !order_quantity) {
      throw new Error("Missing required fields");
    }

    /* 1️⃣ Update main job */
    const result = await client.query(
      `
      UPDATE job_orders
      SET
        party_id = $1,
        fabric_id = $2,
        gsm = $3,
        order_quantity = $4
      WHERE id = $5
      RETURNING *
      `,
      [
        party_id,
        fabric_id,
        gsm,
        order_quantity,
        jobId
      ]
    );

    if (result.rowCount === 0) {
      throw new Error("Job not found");
    }

    /* 2️⃣ Update machines */

    if (machine_ids && machine_ids.length > 0) {

      await client.query(
        `DELETE FROM job_machines WHERE job_id = $1`,
        [jobId]
      );

      for (const machineId of machine_ids) {

        await client.query(
          `
          INSERT INTO job_machines (job_id, machine_id)
          VALUES ($1,$2)
          `,
          [jobId, machineId]
        );
      }
    }

    /* 3️⃣ Update yarns */

    if (yarns && yarns.length > 0) {

      await client.query(
        `DELETE FROM job_yarns WHERE job_id=$1`,
        [jobId]
      );

      for (const yarn of yarns) {
        await client.query(
          `
          INSERT INTO job_yarns (job_id, yarn_id, percentage)
          VALUES ($1,$2,$3,)
          `,
          [
            jobId,
            yarn.yarn_id,
            yarn.percentage || null
          ]
        );
      }
    }
    await client.query("COMMIT");
    res.json({
      success: true,
      job: result.rows[0]
    });
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("❌ UPDATE JOB ERROR:", err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

export default router;