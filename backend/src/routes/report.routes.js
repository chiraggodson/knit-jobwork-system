import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ===== Sungle Job Detail Route ===== */
router.get("/job/:jobNo", async (req, res) => {
  const { jobNo } = req.params;

  try {
    const result = await pool.query(
  `
  SELECT
    j.id AS job_id,
    j.job_no,
    j.party_id,
    j.machine_id,
    j.fabric_id,
    f.name AS fabric_name,
    j.gsm,
    j.order_quantity,
    j.status,
    j.created_at,
    p.name AS party_name,
    m.machine_no,

    COALESCE((
      SELECT SUM(quantity)
      FROM yarn_ledger
      WHERE job_id = j.id
        AND transaction_type = 'ISSUE'
    ),0)::float AS yarn_issued,

    COALESCE((
      SELECT SUM(quantity)
      FROM yarn_ledger
      WHERE job_id = j.id
        AND transaction_type = 'RETURN'
    ),0)::float AS yarn_returned,

    COALESCE((
      SELECT SUM(quantity)
      FROM yarn_ledger
      WHERE job_id = j.id
        AND transaction_type = 'WASTE'
    ),0)::float AS waste,

    COALESCE((
      SELECT SUM(quantity)
      FROM fabric_production
      WHERE job_id = j.id
    ),0)::float AS fabric_produced

  FROM job_orders j
  LEFT JOIN parties p ON p.id = j.party_id
  LEFT JOIN machines m ON m.id = j.machine_id
  LEFT JOIN fabrics f ON f.id = j.fabric_id
  WHERE j.job_no = $1
  `,
  [jobNo]
);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Job not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("❌ JOB DETAIL ERROR:", err);
    res.status(500).json({ error: "Failed to load job detail" });
  }
});


export default router; // ✅ THIS LINE IS MANDATORY
