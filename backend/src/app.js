import express from "express";
import cors from "cors";


import authRoutes from "./routes/auth.routes.js";
import dispatchRoutes from "./routes/dispatch.routes.js";
import fabricsRoutes from "./routes/fabrics.routes.js";
import featuresRoutes from "./routes/features.routes.js";
import jobRoutes from "./routes/job.routes.js";
import machineRoutes from "./routes/machine.routes.js";
import productionRoutes from "./routes/production.routes.js";
import partyRoutes from "./routes/party.routes.js";
import reportRoutes from "./routes/report.routes.js";
import userRoutes from "./routes/users.routes.js";
import yarnRoutes from "./routes/yarn.routes.js";


const app = express();

app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);
app.use("/api/dispatch", dispatchRoutes);
app.use("/api/fabrics", fabricsRoutes);
app.use("/api/features", featuresRoutes);
app.use("/api/jobs", jobRoutes);
app.use("/api/machines", machineRoutes);
app.use("/api/parties", partyRoutes);
app.use("/api/production", productionRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/users", userRoutes);
app.use("/api/yarn", yarnRoutes);

app.use("/uploads", express.static("uploads"));

// 🔴 THIS LINE IS REQUIRED
export default app;
