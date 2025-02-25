import jwt, { JwtPayload, SignOptions } from 'jsonwebtoken';
import dotenv from 'dotenv';
dotenv.config();

/**
 * Generates a JWT access token for user authentication.
 * @param userId - The user's unique ID.
 * @returns A signed JWT access token.
 */
export const generateAccessToken = (userId: string): string => {
  const expiresIn = process.env.JWT_EXPIRES_IN || "10m"; // Default to 10 minutes if not set
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new Error("JWT_SECRET is not defined in the environment variables");
  }

  const token = jwt.sign(
    { id: userId },
    secret,
    { expiresIn } as SignOptions
  );

  console.log(`🛡️ New access token generated for user ID: ${userId} at ${new Date().toISOString()}`);
  return token;
};

export const generateRefreshToken = (userId: string): string => {
  const expiresIn = process.env.REFRESH_TOKEN_EXPIRES_IN || "1d"; // Default to 1 day
  const secret = process.env.REFRESH_TOKEN_SECRET;

  if (!secret) {
    throw new Error("REFRESH_TOKEN_SECRET is not defined in the environment variables");
  }

  const token = jwt.sign(
    { id: userId },
    secret,
    { expiresIn } as SignOptions
  );

  console.log(`🔄 New refresh token generated for user ID: ${userId} at ${new Date().toISOString()}`);
  return token;
};


/**
 * Verifies and decodes a JWT access token.
 * @param token - The JWT token to verify.
 * @returns Decoded payload if valid, otherwise throws an error.
 */
export const verifyAccessToken = (token: string): JwtPayload | string => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET as string);
  } catch (error) {
    throw new Error('Invalid or expired access token.');
  }
};

/**
 * Verifies and decodes a JWT refresh token.
 * @param token - The JWT refresh token to verify.
 * @returns Decoded payload if valid, otherwise throws an error.
 */
export const verifyRefreshToken = (token: string): JwtPayload | string => {
  try {
    return jwt.verify(token, process.env.REFRESH_TOKEN_SECRET as string);
  } catch (error) {
    throw new Error('Invalid or expired refresh token.');
  }
};
