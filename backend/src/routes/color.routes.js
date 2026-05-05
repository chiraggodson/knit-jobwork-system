import express from "express";
import { pool } from "../db.js";

const router = express.Router();

// ✅ GET all colors
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM colors ORDER BY name"
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch colors" });
  }
});

// ✅ CREATE color
router.post("/", async (req, res) => {
  const { name, code } = req.body;

  try {
    await pool.query(
      "INSERT INTO colors (name, code) VALUES ($1, $2)",
      [name, code]
    );

    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create color" });
  }
});

export default router;