import express from "express";
import { pool } from "../db.js";

const router = express.Router();

/* ================= GET ALL FABRICS ================= */
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name, description
      FROM fabrics
      ORDER BY name ASC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("❌ GET FABRICS ERROR:", err);
    res.status(500).json({ error: "Failed to load fabrics" });
  }
});

/* ================= CREATE FABRIC ================= */
router.post("/", async (req, res) => {
  try {
    const { name, description } = req.body;

    if (!name) {
      return res.status(400).json({ error: "Fabric name required" });
    }

    const result = await pool.query(
      `
      INSERT INTO fabrics (name, description)
      VALUES ($1,$2)
      RETURNING *
      `,
      [name, description || null]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("❌ CREATE FABRIC ERROR:", err);
    res.status(500).json({ error: "Failed to create fabric" });
  }
});

/* ================= UPDATE FABRIC ================= */
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description } = req.body;

    const result = await pool.query(
      `
      UPDATE fabrics
      SET name = $1,
          description = $2
      WHERE id = $3
      RETURNING *
      `,
      [name, description, id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error("❌ UPDATE FABRIC ERROR:", err);
    res.status(500).json({ error: "Failed to update fabric" });
  }
});

/* ================= DELETE FABRIC ================= */
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    await pool.query(
      `DELETE FROM fabrics WHERE id = $1`,
      [id]
    );

    res.json({ message: "Fabric deleted" });
  } catch (err) {
    console.error("❌ DELETE FABRIC ERROR:", err);
    res.status(500).json({ error: "Cannot delete fabric (maybe used in jobs)" });
  }
});

export default router;