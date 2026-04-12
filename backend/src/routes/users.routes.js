import express from "express";
import { authMiddleware, adminOnly } from "../middleware/auth.js";
import bcrypt from "bcryptjs";
import { pool } from "../db.js";

const router = express.Router();

/* ================= GET USERS ================= */

router.get("/", authMiddleware, adminOnly, async (req, res) => {
  try {

    const result = await pool.query(
      "SELECT id, name, username, role, created_at FROM users ORDER BY id"
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch users" });
  }
});


/* ================= ADD USER ================= */

router.post("/", authMiddleware, adminOnly, async (req, res) => {

  const { name, username, password, role } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);

  try {

    const result = await pool.query(
      `INSERT INTO users (name, username, password, role)
       VALUES ($1,$2,$3,$4)
       RETURNING *`,
      [name, username, password, role]
    );

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create user" });
  }
});


/* ================= DELETE USER ================= */

router.delete("/:id", authMiddleware, adminOnly, async (req, res) => {

  const { id } = req.params;

  try {

    await pool.query(
      "DELETE FROM users WHERE id = $1",
      [id]
    );

    res.json({ success: true });

  } catch (err) {

    console.error(err);
    res.status(500).json({ error: "Failed to delete user" });

  }

});

export default router;