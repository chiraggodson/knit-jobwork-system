import pkg from "pg";
import { env } from "./config/env.js";

const { Pool } = pkg;

export const pool = new Pool({
  host: env.DB_HOST,
  user: env.DB_USER,
  password: env.DB_PASS,
  database: env.DB_NAME,
  port: 5432,

  // Connection pool settings
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Connection event
pool.on("connect", () => {
  if (env.NODE_ENV === "development") {
    console.log("📦 PostgreSQL connected");
  }
});

// Unexpected errors
pool.on("error", (err) => {
  console.error("❌ PostgreSQL Pool Error:", err.message);
});