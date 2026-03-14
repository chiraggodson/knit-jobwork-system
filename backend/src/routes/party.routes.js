import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/**
 * GET all parties
 * URL: /api/parties
 */
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, name FROM parties ORDER BY name"
    );
    res.json(result.rows);
  } catch (err) {
    console.error("GET /api/parties error:", err);
    res.status(500).json({ error: "Failed to fetch parties" });
  }
});

/**
 * CREATE party
 * URL: /api/parties
 */
router.post("/", async (req, res) => {
  try {
    const { name, phone } = req.body;

    if (!name) {
      return res.status(400).json({ error: "Party name required" });
    }

    const result = await pool.query(
      "INSERT INTO parties (name, phone) VALUES ($1, $2) RETURNING *",
      [name, phone || null]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("POST /api/parties error:", err);
    res.status(500).json({ error: "Failed to create party" });
  }
});

export default router;
