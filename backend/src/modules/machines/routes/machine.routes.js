import express from "express";

import {
  createMachineController,
  getMachinesController,
  updateMachineStatusController,
  updateMachinePerformanceController,
  deleteMachineController,
} from "../controllers/machine.controller.js";

const router = express.Router();

/*
=================================
MACHINE ROUTES
=================================
*/

router.post("/", createMachineController);

router.get("/", getMachinesController);

router.put("/:id/status", updateMachineStatusController);

router.put(
  "/:id/performance",
  updateMachinePerformanceController
);

router.delete("/:id", deleteMachineController);

export default router;