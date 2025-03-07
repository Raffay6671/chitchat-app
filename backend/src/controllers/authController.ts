import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt, { JwtPayload } from "jsonwebtoken";
import User from "../models/user";
import dotenv from "dotenv";
import { generateAccessToken, generateRefreshToken } from "../utils/tokenUtils";

// Extend Request type to include multer file
interface MulterRequest extends Request {
  file: Express.Multer.File;
}

dotenv.config();

// ✅ Helper function to extract first name from username
const extractFirstName = (username: string): string => {
  return username.split(" ")[0]; // Take the first part before the space
};

// ✅ User Registration
export const registerUser = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res
        .status(409)
        .json({ message: "User already exists with this email" });
    }

    const existingUsername = await User.findOne({ where: { username } });
    if (existingUsername) {
      return res.status(409).json({ message: "Username is already taken" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    const displayName = extractFirstName(username);

    const newUser = await User.create({
      username,
      email,
      password: hashedPassword,
      displayName,
    });

    const { password: _, ...userWithoutPassword } = newUser.toJSON();

    return res.status(201).json({
      message: "User registered successfully",
      user: userWithoutPassword,
    });
  } catch (error) {
    console.error("Registration Error:", error);
    return res.status(500).json({ message: "Server error" });
  }
};
export const loginUser = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res
        .status(400)
        .json({ message: "Email and password are required" });
    }

    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // ✅ Generate Tokens
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // ✅ Store Refresh Token in Database
    await User.update({ refreshToken }, { where: { id: user.id } });

    return res.status(200).json({
      message: "Login successful",
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
      },
      accessToken,
      refreshToken,
    });
  } catch (error) {
    console.error("Login Error:", error);
    return res.status(500).json({ message: "Server error" });
  }
};
export const refreshAccessToken = async (
  req: Request,
  res: Response
): Promise<Response> => {
  console.log("🔄 Refresh token endpoint hit");

  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ message: "Refresh token is required" });
    }

    let decoded: JwtPayload;
    try {
      decoded = jwt.verify(
        refreshToken,
        process.env.REFRESH_TOKEN_SECRET!
      ) as JwtPayload;
      console.log(`🔄 Refresh token used for user ID: ${decoded.id}`);
    } catch (error) {
      return res
        .status(403)
        .json({ message: "Invalid or expired refresh token" });
    }

    const userId = decoded.id;

    // ✅ Check if refresh token exists in database
    const user = await User.findOne({ where: { id: userId } });

    if (!user || user.refreshToken !== refreshToken) {
      return res
        .status(403)
        .json({ message: "Invalid or expired refresh token" });
    }

    // ✅ Generate a new access token
    const newAccessToken = generateAccessToken(userId);
    console.log(`✅ New access token generated for user ID: ${userId}`);

    return res.status(200).json({
      accessToken: newAccessToken,
    });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Server error during token refresh" });
  }
};

// ✅ Upload Profile Picture Function
export const uploadProfilePicture = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { userId } = req.body;

    // Properly handle multer file validation
    if (!req.file) {
      res.status(400).json({ message: "No file uploaded" });
      return;
    }

    const imageUrl = `/uploads/${req.file.filename}`;

    // Update user's profile picture in the database
    await User.update({ profilePicture: imageUrl }, { where: { id: userId } });

    console.log(
      `🖼️ Profile picture uploaded for user ID: ${userId} at ${new Date().toISOString()}`
    );

    res.status(200).json({
      message: "Profile picture uploaded successfully",
      imageUrl,
    });
  } catch (error) {
    console.error("Profile Picture Upload Error:", error);
    res.status(500).json({ message: "Failed to upload profile picture" });
  }
};

// ✅ Fetch User Data Using Access Token
export const getUserData = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = (req as any).user.id; // Extract user ID from token
    const user = await User.findByPk(userId);

    if (!user) {
      res.status(404).json({ message: "User not found" });
      return;
    }

    // Remove sensitive information (password)
    const { password, ...userData } = user.toJSON();

    res.status(200).json({
      message: "User data fetched successfully",
      user: userData,
    });
  } catch (error) {
    console.error("Error fetching user data:", error);
    res.status(500).json({ message: "Server error fetching user data" });
  }
};

// Controller function to get all users
export const getAllUsers = async (req: Request, res: Response) => {
  try {
    // Fetch all users from the database
    const users = await User.findAll({
      attributes: ["id", "username", "displayName", "profilePicture"], // Specify fields to fetch
    });
    res.status(200).json({ users });
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ message: "Server error while fetching users" });
  }
};

// ✅ Logout function to remove refresh token from DB
export const logoutUser = async (req: Request, res: Response) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ message: "User ID is required" });
    }

    // ✅ Remove refresh token from database
    await User.update({ refreshToken: null }, { where: { id: userId } });

    res.status(200).json({ message: "User logged out successfully" });
  } catch (error) {
    console.error("Logout Error:", error);
    res.status(500).json({ message: "Server error during logout" });
  }
};
