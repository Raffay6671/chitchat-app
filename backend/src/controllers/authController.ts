import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt, { JwtPayload } from 'jsonwebtoken';
import User from '../models/user';
import dotenv from 'dotenv';
import { generateAccessToken, generateRefreshToken } from '../utils/tokenUtils';

// Extend Request type to include multer file
interface MulterRequest extends Request {
  file: Express.Multer.File;
}

dotenv.config();

// ✅ Helper function to extract first name from username
const extractFirstName = (username: string): string => {
  return username.split(' ')[0]; // Take the first part before the space
};

// ✅ User Registration
export const registerUser = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(409).json({ message: 'User already exists with this email' });
    }

    const existingUsername = await User.findOne({ where: { username } });
    if (existingUsername) {
      return res.status(409).json({ message: 'Username is already taken' });
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

    return res.status(201).json({ message: 'User registered successfully', user: userWithoutPassword });
  } catch (error) {
    console.error('Registration Error:', error);
    return res.status(500).json({ message: 'Server error' });
  }
};

// ✅ User Login with JWT Tokens
export const loginUser = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    console.log("Access Token:", accessToken);
    console.log("Refresh Token:", refreshToken);

    const { password: _, ...userWithoutPassword } = user.toJSON();

    return res.status(200).json({
      message: 'Login successful',
      user: userWithoutPassword,
      accessToken,
      refreshToken,
    });
  } catch (error) {
    console.error('Login Error:', error);
    return res.status(500).json({ message: 'Server error' });
  }
};

// ✅ Refresh Access Token with Logging
export const refreshAccessToken = async (req: Request, res: Response): Promise<Response> => {
  console.log("🔄 Refresh token endpoint hit");

  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      console.log('No refresh token provided');
      return res.status(400).json({ message: 'Refresh token is required' });
    }

    let decoded: JwtPayload;
    try {
      decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET!) as JwtPayload;
      console.log(`🔄 Refresh token accessed for user ID: ${decoded.id} at ${new Date().toISOString()}`);
    } catch (error) {
      console.log('❌ Invalid or expired refresh token attempt');
      return res.status(403).json({ message: 'Invalid or expired refresh token' });
    }

    const userId = decoded.id;
    const newAccessToken = generateAccessToken(userId);

    console.log(`✅ New access token generated for user ID: ${userId} at ${new Date().toISOString()}`);

    return res.status(200).json({
      accessToken: newAccessToken,
    });
  } catch (error) {
    console.error('❌ Token Refresh Error:', error);
    return res.status(500).json({ message: 'Server error during token refresh' });
  }
};

// ✅ Upload Profile Picture Function
export const uploadProfilePicture = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = req.body;

    // Properly handle multer file validation
    if (!req.file) {
      res.status(400).json({ message: 'No file uploaded' });
      return;
    }

    const imageUrl = `/uploads/${req.file.filename}`;

    // Update user's profile picture in the database
    await User.update(
      { profilePicture: imageUrl },
      { where: { id: userId } }
    );

    console.log(`🖼️ Profile picture uploaded for user ID: ${userId} at ${new Date().toISOString()}`);

    res.status(200).json({
      message: 'Profile picture uploaded successfully',
      imageUrl
    });
  } catch (error) {
    console.error('Profile Picture Upload Error:', error);
    res.status(500).json({ message: 'Failed to upload profile picture' });
  }
};

// ✅ Fetch User Data Using Access Token
export const getUserData = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.id; // Extract user ID from token
    const user = await User.findByPk(userId);

    if (!user) {
      res.status(404).json({ message: 'User not found' });
      return;
    }

    // Remove sensitive information (password)
    const { password, ...userData } = user.toJSON();

    res.status(200).json({
      message: 'User data fetched successfully',
      user: userData,
    });
  } catch (error) {
    console.error('Error fetching user data:', error);
    res.status(500).json({ message: 'Server error fetching user data' });
  }
};
