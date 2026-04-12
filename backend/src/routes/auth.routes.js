import express from "express";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import { pool } from "../db.js";

const router = express.Router();

const SECRET = process.env.JWT_SECRET;

// 🔐 ROLE → PERMISSIONS MAP
const rolePermissions = {
  admin: ["ALL"],

  supervisor: [
    "VIEW_DASHBOARD",
    "VIEW_MACHINES",
    "EDIT_MACHINE_STATUS",
    "VIEW_REPORTS",
    "VIEW_JOBS"
  ],

  operator: [
    "VIEW_DASHBOARD",
    "VIEW_MACHINES"
  ]
};

// ✅ LOGIN
router.post("/login", async (req, res) => {
  const { username, password } = req.body;

  try {
    const result = await pool.query(
      "SELECT * FROM users WHERE username = $1",
      [username]
    );

    if (result.rows.length === 0) {
      return res.json({ success: false, message: "User not found" });
    }

    const user = result.rows[0];

    // 🔐 Compare entered password with hashed password in DB
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.json({ success: false, message: "Wrong password" });
    }

    const permissions = rolePermissions[user.role] || [];

    const token = jwt.sign(
      {
        id: user.id,
        role: user.role,
        username: user.username,
        permissions,
      },
      SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        name: user.name,
        role: user.role,
        permissions,
      },
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Login failed" });
  }
});

export default router;