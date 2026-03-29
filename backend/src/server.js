import app from "./app.js";
import { pool } from "./db.js";

const PORT = process.env.PORT || 4000;
const HOST = "0.0.0.0";

async function startServer() {
try {
// Test DB connection
await pool.query("SELECT 1");
console.log("✅ PostgreSQL connected");


const server = app.listen(PORT, HOST, () => {
  console.log("=================================");
  console.log("🚀 BBJOMS Started");
  console.log(`🌐 Server: http://localhost:${PORT}`);
  console.log(`🌐 Network: http://${HOST}:${PORT}`);
  console.log("=================================");
});

// Graceful shutdown
process.on("SIGINT", async () => {
  console.log("\n🛑 Shutting down server...");
  await pool.end();
  server.close(() => {
    console.log("✅ Server closed");
    process.exit(0);
  });
});


} catch (error) {
console.error("❌ Database connection failed");
console.error(error);
process.exit(1);
}
}

startServer();
