import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ================= RESET TRANSACTIONS ================= */

router.post("/reset-transactions", async (req, res) => {
  try {

    await pool.query(`
      TRUNCATE
        dispatch_items,
        dispatch,
        production,
        yarn_waste,
        yarn_return,
        yarn_issue,
        yarn_stock,
        yarn_lots,
        job_machines,
        jobs
      RESTART IDENTITY CASCADE
    `);

    res.json({
      message: "Factory transactions reset successfully"
    });

  } catch (err) {

    console.error("RESET ERROR:", err);
    res.status(500).json({ error: err.message });

  }
});

export default router;