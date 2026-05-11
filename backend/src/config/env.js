import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

// ES Module support
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load .env
dotenv.config({
  path: path.join(__dirname, "../../.env"),
});

// Validate required env vars
const requiredEnvVars = [
  "DB_HOST",
  "DB_USER",
  "DB_PASS",
  "DB_NAME",
  "JWT_SECRET",
];

for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    console.error(`❌ Missing environment variable: ${envVar}`);
    process.exit(1);
  }
}

export const env = {
  PORT: process.env.PORT || 4000,

  DB_HOST: process.env.DB_HOST,
  DB_USER: process.env.DB_USER,
  DB_PASS: process.env.DB_PASS,
  DB_NAME: process.env.DB_NAME,

  JWT_SECRET: process.env.JWT_SECRET,

  NODE_ENV: process.env.NODE_ENV || "development",
};