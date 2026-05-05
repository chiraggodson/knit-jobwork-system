import express from "express";
import cors from "cors";

// Routes
import authRoutes from "./routes/auth.routes.js";
import dispatchRoutes from "./routes/dispatch.routes.js";
import dispatchMasterRoutes from "./routes/dispatch.master.routes.js";
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
import employeeRoutes from "./routes/employee.routes.js";
import colorRoutes from "./routes/color.routes.js";



// Auth middleware
import { authMiddleware } from "./middleware/auth.js";

const app = express();

/*
# MIDDLEWARE
*/

// Better CORS (important for iPhone + factory network)
app.use(cors({
  origin: "*", // later we can restrict
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logger (VERY useful)
app.use((req, res, next) => {
  console.log(`📡 ${req.method} ${req.originalUrl}`);
  next();
});

/*
# PUBLIC ROUTES
*/
app.use("/api/auth", authRoutes);

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
# PROTECTED ROUTES
*/
app.use("/api/dispatch", authMiddleware, dispatchRoutes);
app.use("/api/dispatch", authMiddleware, dispatchMasterRoutes);
app.use("/api/fabrics", authMiddleware, fabricsRoutes);
app.use("/api/features", authMiddleware, featuresRoutes);
app.use("/api/jobs", authMiddleware, jobRoutes);
app.use("/api/machines", authMiddleware, machineRoutes);
app.use("/api/parties", authMiddleware, partyRoutes);
app.use("/api/parties/upload", authMiddleware, partyUploadRoutes);
app.use("/api/production", authMiddleware, productionRoutes);
app.use("/api/reports", authMiddleware, reportRoutes);
app.use("/api/users", authMiddleware, userRoutes);
app.use("/api/yarn", authMiddleware, yarnRoutes);
app.use("/api/employees", authMiddleware, employeeRoutes);
app.use("/api/colors", colorRoutes);
/*
# STATIC FILES
*/
app.use("/uploads", express.static("uploads"));

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
});

/*
# GLOBAL ERROR HANDLER
*/
app.use((err, req, res, next) => {
  console.error("❌ Error:", err.message);
  res.status(500).json({
    error: "Internal Server Error",
  });
});

export default app;