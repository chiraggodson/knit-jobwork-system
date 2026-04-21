import express from "express";
import { AppDataSource } from "../config/data-source.js";
import { Employee } from "../entities/Employee.js";

const router = express.Router();

const repo = AppDataSource.getRepository(Employee);

/// GET all employees
router.get("/", async (req, res) => {
  try {
    const employees = await repo.find();
    res.json(employees);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/// CREATE employee
router.post("/", async (req, res) => {
  try {
    const emp = repo.create(req.body);
    const result = await repo.save(emp);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;