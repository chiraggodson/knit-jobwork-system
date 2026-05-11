import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";

// Routes
import authRoutes from "./routes/auth.routes.js";
import dispatchRoutes from "./routes/dispatch.routes.js";
import dispatchMasterRoutes from "./routes/dispatch.master.routes.js";
import fabricsRoutes from "./routes/fabrics.routes.js";
import featuresRoutes from "./routes/features.routes.js";
import jobRoutes from "./routes/job.routes.js";
import machineRoutes from "./modules/machines/routes/machine.routes.js";
import productionRoutes from "./routes/production.routes.js";
import partyRoutes from "./routes/party.routes.js";
import partyUploadRoutes from "./routes/partyUpload.routes.js";
import reportRoutes from "./routes/report.routes.js";
import userRoutes from "./routes/users.routes.js";
import yarnRoutes from "./routes/yarn.routes.js";
import employeeRoutes from "./routes/employee.routes.js";
import colorRoutes from "./routes/color.routes.js";
import yarnChallanRoutes from "./modules/yarn/routes/yarnChallan.routes.js";

// Middleware
import { authMiddleware } from "./middleware/auth.js";
import { requestLogger } from "./middleware/requestLogger.js";
import { errorHandler } from "./middleware/errorHandler.js";
import { notFound } from "./middleware/notFound.js";

const app = express();

/*
=================================
SECURITY
=================================
*/

// Secure headers
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 mins
  max: 500, // requests per IP
  message: "Too many requests, please try again later.",
});

app.use(limiter);

/*
=================================
CORS
=================================
*/

app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));

/*
=================================
BODY PARSING
=================================
*/

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

/*
=================================
LOGGING
=================================
*/

app.use(requestLogger);

/*
=================================
HEALTH CHECK
=================================
*/

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "BBJOMS API running 🚀",
  });
});

/*
=================================
PUBLIC ROUTES
=================================
*/

app.use("/api/auth", authRoutes);

/*
=================================
PROTECTED ROUTES
=================================
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

app.use("/api/colors", authMiddleware, colorRoutes);

app.use("/api/yarn-challans", authMiddleware, yarnChallanRoutes);

/*
=================================
STATIC FILES
=================================
*/

app.use("/uploads", express.static("uploads"));

/*
=================================
ROOT
=================================
*/

app.get("/", (req, res) => {
  res.send("BBJOMS API Running 🚀");
});

/*
=================================
404 HANDLER
=================================
*/

app.use(notFound);

/*
=================================
GLOBAL ERROR HANDLER
=================================
*/

app.use(errorHandler);

export default app;