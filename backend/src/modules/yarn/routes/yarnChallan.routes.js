import express from "express";
import { createYarnChallan } from "../controllers/yarnChallan.controller.js";
import { authMiddleware } from "../../../middleware/auth.js";

const router = express.Router();

/*
=================================
CREATE YARN CHALLAN
=================================
*/

router.post("/", authMiddleware, createYarnChallan);

export default router;