import express from "express";
import { pool } from "../db.js";

const router = express.Router();

// GET ALL FEATURES
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT key, enabled FROM features"
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to load features" });
  }
});

export default router;
