import express from "express";
import { authMiddleware, adminOnly } from "../middleware/auth.js";

const router = express.Router();

router.get(
  "/dashboard",
  authMiddleware,   // ✅ first
  adminOnly,        // ✅ then role check
  async (req, res) => {
    res.json({ message: "Dashboard data" });
  }
);dd