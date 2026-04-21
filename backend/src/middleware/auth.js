import jwt from "jsonwebtoken";

const SECRET = process.env.JWT_SECRET;
console.log("JWT SECRET IN MIDDLEWARE:", SECRET);
export function authMiddleware(req, res, next) {
  try {
    const header = req.headers.authorization;

    if (!header) {
      return res.status(401).json({ error: "No token" });
    }

    const token = header.split(" ")[1];

    const decoded = jwt.verify(token, SECRET);

    req.user = decoded;

    next();
  } catch (err) {
    return res.status(401).json({ error: "Invalid token" });
  }
}

export function adminOnly(req, res, next) {
  if (req.user.role !== "admin") {
    return res.status(403).json({ error: "Access denied" });
  }
  next();
}