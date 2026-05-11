import jwt from "jsonwebtoken";
import { env } from "../config/env.js";

/*
=================================
AUTH MIDDLEWARE
=================================
*/

export function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    // Check header
    if (!authHeader) {
      return res.status(401).json({
        success: false,
        message: "Authorization token missing",
      });
    }

    // Check Bearer format
    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Invalid authorization format",
      });
    }

    // Extract token
    const token = authHeader.split(" ")[1];

    // Verify token
    const decoded = jwt.verify(token, env.JWT_SECRET);

    // Attach user to request
    req.user = decoded;

    next();

  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
}

/*
=================================
ROLE-BASED ACCESS CONTROL
=================================
*/

export function requireRole(...allowedRoles) {
  return (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      if (!allowedRoles.includes(req.user.role)) {
        return res.status(403).json({
          success: false,
          message: "Access denied",
        });
      }

      next();

    } catch (error) {
      return res.status(500).json({
        success: false,
        message: "Authorization error",
      });
    }
  };
}

/*
=================================
ADMIN ONLY
=================================
*/

export const adminOnly = requireRole("admin");