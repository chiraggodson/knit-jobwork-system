/* -- Old Version
import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ================= CREATE MACHINE ================= 
router.post("/", async (req, res) => {
  try {
    const { machine_no } = req.body;

    if (!machine_no) {
      return res.status(400).json({ error: "machine_no required" });
    }

    const result = await pool.query(
      `INSERT INTO machines (machine_no)
       VALUES ($1)
       RETURNING *`,
      [machine_no]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("CREATE MACHINE ERROR:", err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ================= GET ALL MACHINES ================= 
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        m.id,
        m.machine_no,
        m.status,
        m.rpm,
        m.counter,
        m.roll_size,

        /* kg per hour 
        COALESCE(
          (COALESCE(m.rpm,0) * 60) /
          NULLIF(COALESCE(m.counter,1),0)
        ,0)::float AS kg_per_hour

      FROM machines m
      ORDER BY m.machine_no::int;
    `);

    const machines = result.rows.map(m => {

      const kg24h = m.kg_per_hour * 24;

      const estimatedRolls =
        m.roll_size > 0
          ? Math.floor(kg24h / m.roll_size)
          : 0;

      return {
        ...m,
        kg_24h: kg24h,
        estimated_rolls_24h: estimatedRolls
      };
    });

    res.json(machines);

  } catch (err) {
    console.error("GET MACHINES ERROR:", err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ================= UPDATE MACHINE STATUS ================= 
router.put("/:id/status", async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const result = await pool.query(
      `UPDATE machines SET status=$1 WHERE id=$2 RETURNING *`,
      [status, id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error("UPDATE MACHINE ERROR:", err.message);
    res.status(500).json({ error: err.message });
  }
});

router.put("/:id/performance", async (req, res) => {
  try {
    const { id } = req.params;
    const { rpm, counter, roll_size } = req.body;

    if (counter == 0) {
      return res.status(400).json({ error: "Counter cannot be zero" });
    }

    const result = await pool.query(
      `
      UPDATE machines
      SET rpm = $1,
          counter = $2,
          roll_size = $3
      WHERE id = $4
      RETURNING *
      `,
      [rpm ?? 0, counter ?? 1, roll_size ?? 0, id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Update failed" });
  }
});

export default router;
*/ /* -  old Version */

import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ================= VALID MACHINE STATUSES ================= */

const VALID_STATUSES = [
  "RUNNING",
  "STOPPED",
  "CLEANING",
  "SAMPLING",
  "NO_ORDER",
  "YARN_REQUIRED"
];

/* ================= CREATE MACHINE ================= */

router.post("/", async (req, res) => {
  try {
    const { machine_no } = req.body;

    if (!machine_no) {
      return res.status(400).json({ error: "machine_no required" });
    }

    const result = await pool.query(
      `INSERT INTO machines (machine_no)
       VALUES ($1)
       RETURNING *`,
      [machine_no]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {
    console.error("CREATE MACHINE ERROR:", err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ================= GET ALL MACHINES ================= */

router.get("/", async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT
        m.id,
        m.machine_no,
        m.status,
        m.rpm,
        m.counter,
        m.roll_size,

        COALESCE(
          (COALESCE(m.rpm,0) * 60) /
          NULLIF(COALESCE(m.counter,1),0)
        ,0)::float AS kg_per_hour

      FROM machines m
      ORDER BY m.machine_no::int;
    `);

    const machines = result.rows.map(m => {

      const kg24h = m.kg_per_hour * 24;

      const estimatedRolls =
        m.roll_size > 0
          ? Math.floor(kg24h / m.roll_size)
          : 0;

      return {
        ...m,
        kg_24h: kg24h,
        estimated_rolls_24h: estimatedRolls
      };
    });

    res.json(machines);

  } catch (err) {
    console.error("GET MACHINES ERROR:", err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ================= UPDATE MACHINE STATUS ================= */

router.put("/:id/status", async (req, res) => {
  try {

    const { id } = req.params;
    const { status } = req.body;

    if (!VALID_STATUSES.includes(status)) {
      return res.status(400).json({
        error: "Invalid status"
      });
    }

    const result = await pool.query(
      `UPDATE machines
       SET status=$1
       WHERE id=$2
       RETURNING *`,
      [status, id]
    );

    res.json(result.rows[0]);

  } catch (err) {
    console.error("UPDATE MACHINE ERROR:", err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ================= UPDATE PERFORMANCE ================= */

router.put("/:id/performance", async (req, res) => {

  try {

    const { id } = req.params;
    const { rpm, counter, roll_size } = req.body;

    if (counter == 0) {
      return res.status(400).json({
        error: "Counter cannot be zero"
      });
    }

    const result = await pool.query(
      `
      UPDATE machines
      SET rpm = $1,
          counter = $2,
          roll_size = $3
      WHERE id = $4
      RETURNING *
      `,
      [rpm ?? 0, counter ?? 1, roll_size ?? 0, id]
    );

    res.json(result.rows[0]);

  } catch (err) {
    console.error("UPDATE PERFORMANCE ERROR:", err.message);
    res.status(500).json({ error: "Update failed" });
  }
});

/* ================= DELETE MACHINE ================= */

router.delete("/:id", async (req, res) => {

  try {

    const { id } = req.params;

    await pool.query(
      `DELETE FROM machines WHERE id=$1`,
      [id]
    );

    res.json({ message: "Machine deleted" });

  } catch (err) {

    console.error("DELETE MACHINE ERROR:", err.message);
    res.status(500).json({ error: err.message });

  }

});

export default router;

