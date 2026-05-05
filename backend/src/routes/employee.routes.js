import express from "express";
import { pool } from "../db.js"; // 🔥 same as your other routes

const router = express.Router();

/// GET employees
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM employees ORDER BY id DESC"
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch employees" });
  }
});

/// CREATE employee
router.post("/", async (req, res) => {
  try {
    const {
      emp_id,
      first_name,
      last_name,
      father_name,
      dob,
      address,
      aadhar,
      phone,
      emergency_contact,
      esi_number,
      group,
      department,
      role,
      pay_rate,
      pay_method,
      pay_schedule,
      status,
    } = req.body;

    const result = await pool.query(
      `INSERT INTO employees (
        emp_id, first_name, last_name, father_name,
        dob, address, aadhar, phone, emergency_contact,
        esi_number, "group", department, role,
        pay_rate, pay_method, pay_schedule, status
      ) VALUES (
        $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17
      ) RETURNING *`,
      [
        emp_id,
        first_name,
        last_name,
        father_name,
        dob,
        address,
        aadhar,
        phone,
        emergency_contact,
        esi_number,
        group,
        department,
        role,
        pay_rate,
        pay_method,
        pay_schedule,
        status,
      ]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Insert failed" });
  }
});

export default router;