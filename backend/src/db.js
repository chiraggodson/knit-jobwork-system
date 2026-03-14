import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

// 👇 required for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 👇 force exact .env path
dotenv.config({
  path: path.join(__dirname, "../.env"),
});

import pkg from "pg";
const { Pool } = pkg;


export const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS, 
  database: process.env.DB_NAME,
  port: 5432,
});
