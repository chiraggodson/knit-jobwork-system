import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import pkg from "pg";

const { Pool } = pkg;

// ES module fix
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load env
dotenv.config({
path: path.join(__dirname, "../.env"),
});

// Create pool
export const pool = new Pool({
host: process.env.DB_HOST,
user: process.env.DB_USER,
password: process.env.DB_PASS,
database: process.env.DB_NAME,
port: 5432,

// 🔥 Production-ready tweaks
max: 20, // max clients
idleTimeoutMillis: 30000,
connectionTimeoutMillis: 2000,
});

// Log connection
pool.on("connect", () => {
console.log("📦 New DB connection");
});

// Error handling
pool.on("error", (err) => {
console.error("❌ Unexpected DB error", err);
});
