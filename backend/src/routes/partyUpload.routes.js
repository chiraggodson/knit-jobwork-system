import express from "express";
import multer from "multer";
import csv from "csv-parser";
import fs from "fs";
import { pool } from "../db.js";

const router = express.Router();
const upload = multer({ dest: "uploads/" });

router.post("/upload", upload.single("file"), async (req, res) => {

  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded" });
  }

  const filePath = req.file.path;
  let inserted = 0;

  const rows = [];

  fs.createReadStream(filePath)
    .pipe(csv({ headers: ["name", "phone"] }))
    .on("data", (data) => rows.push(data))
    .on("end", async () => {

      try {

        for (const row of rows) {

          const name = row.name?.trim();
          const phone = row.phone?.trim();

          if (!name) continue;

          console.log("Inserting:", name, phone);

          await pool.query(
            "INSERT INTO parties (name, phone) VALUES ($1,$2)",
            [name, phone || null]
          );

          inserted++;
        }

        fs.unlinkSync(filePath);

        res.json({
          message: "Upload completed",
          inserted
        });

      } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Upload failed" });
      }

    });

});

export default router;