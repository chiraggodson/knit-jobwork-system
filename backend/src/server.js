import app from "./app.js";
import { pool } from "./db.js";

const PORT = process.env.PORT || 4000;

pool.query("SELECT 1")
  .then(() => {
    console.log("✅ PostgreSQL connected");
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`🚀 Server running on port ${PORT} (Lan Enabled)`);
    });
  })
  .catch((err) => {
    console.error("❌ DB connection failed", err);
  });
