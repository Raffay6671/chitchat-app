import { Router, Request, Response } from "express";
import {
  registerUser,
  loginUser,
  refreshAccessToken,
} from "../controllers/authController";
import { verifyAccessToken } from "../middlewares/authMiddleware"; // ✅ Import token verification middleware
import { upload } from "../middlewares/uploadMiddleware";
import { uploadProfilePicture } from "../controllers/authController";
import { getUserData } from "../controllers/authController";
import { getAllUsers } from "../controllers/authController";

const router = Router();

// ✅ Route for user registration
router.post("/register", async (req: Request, res: Response) => {
  try {
    await registerUser(req, res);
  } catch (error) {
    console.error("Registration Error:", error);
    res
      .status(500)
      .json({ message: "Internal server error during registration" });
  }
});

// ✅ Route for user login
router.post("/login", async (req: Request, res: Response) => {
  try {
    await loginUser(req, res);
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ message: "Internal server error during login" });
  }
});

// ✅ Route to refresh access token
router.post("/refresh-token", async (req: Request, res: Response) => {
  try {
    await refreshAccessToken(req, res);
  } catch (error) {
    console.error("Token Refresh Error:", error);
    res
      .status(500)
      .json({ message: "Internal server error during token refresh" });
  }
});

router.post(
  "/upload-profile",
  upload.single("profilePicture"),
  uploadProfilePicture
);

router.get("/user", verifyAccessToken, getUserData);

router.get("/users", verifyAccessToken, getAllUsers); // New route to fetch all users

// ✅ Protected route - Requires valid Access Token
router.get("/protected", verifyAccessToken, (req: Request, res: Response) => {
  const user = (req as any).user;
  res.status(200).json({
    message: "Access granted to protected route!",
    user,
  });
});

export default router;
