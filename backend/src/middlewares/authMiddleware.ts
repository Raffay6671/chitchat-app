import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

// ✅ Middleware to verify access token
export const verifyAccessToken = (req: Request, res: Response, next: NextFunction): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Extract token from Bearer token

  if (!token) {
    res.status(401).json({ message: 'Access token missing' });
    return; // Stop further execution
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as jwt.JwtPayload;
    (req as any).user = decoded; // Attach decoded user info to request
    next(); // Move to next middleware/handler
  } catch (error) {
    console.log('❌ Invalid or expired access token.');
    res.status(403).json({ message: 'Invalid or expired access token' });
  }
};
