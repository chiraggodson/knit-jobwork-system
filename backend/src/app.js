import express from "express";
import cors from "cors";

// Routes
import authRoutes from "./routes/auth.routes.js";
import dispatchRoutes from "./routes/dispatch.routes.js";
import dispatchMasterRoutes  from "./routes/dispatch.master.routes.js";

import fabricsRoutes from "./routes/fabrics.routes.js";
import featuresRoutes from "./routes/features.routes.js";
import jobRoutes from "./routes/job.routes.js";
import machineRoutes from "./routes/machine.routes.js";
import productionRoutes from "./routes/production.routes.js";
import partyRoutes from "./routes/party.routes.js";
import partyUploadRoutes from "./routes/partyUpload.routes.js";
import reportRoutes from "./routes/report.routes.js";
import userRoutes from "./routes/users.routes.js";
import yarnRoutes from "./routes/yarn.routes.js";

const app = express();


 /*
# MIDDLEWARE
*/
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

 /*
# API ROUTES
*/
app.use("/api/auth", authRoutes);
app.use("/api/dispatch", dispatchRoutes);
app.use("/api/dispatch", dispatchMasterRoutes);
app.use("/api/fabrics", fabricsRoutes);
app.use("/api/features", featuresRoutes);
app.use("/api/jobs", jobRoutes);
app.use("/api/machines", machineRoutes);
app.use("/api/parties", partyRoutes);
app.use("/api/parties/upload", partyUploadRoutes); // FIXED route separation
app.use("/api/production", productionRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/users", userRoutes);
app.use("/api/yarn", yarnRoutes);

/*
 STATIC FILES
*/
app.use("/uploads", express.static("uploads"));

 /*
# HEALTH CHECK
*/
app.get("/api/health", (req, res) => {
  res.json({
    status: "OK",
    message: "BBJOMS API running 🚀",
  });
});

 /*
# ROOT
*/
app.get("/", (req, res) => {
res.send("BBJOMS API Running 🚀");
});

/*
# 404 HANDLER
*/
app.use((req, res) => {
  res.status(404).json({
    error: "API route not found",
    });
  }
);

/*
# GLOBAL ERROR HANDLER
*/
app.use((err, req, res, next) => {
console.error("❌ Error:", err.message);

res.status(500).json({
error: "Internal Server Error",
});
});

/*
# EXPORT
*/
export default app;