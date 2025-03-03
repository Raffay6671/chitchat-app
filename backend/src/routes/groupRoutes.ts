import { Router } from "express";
import {
  createGroup,
  getGroups,
  getGroupMessages,
} from "../controllers/groupController";
import { verifyAccessToken } from "../middlewares/authMiddleware";

const router = Router();

// Create a new group with invited members
router.post("/", verifyAccessToken, createGroup);

// Get all groups for the logged-in user (includes group members)
router.get("/", verifyAccessToken, getGroups);

// NEW: Fetch all messages for a specific group
router.get("/:groupId/messages", verifyAccessToken, getGroupMessages);

export default router;
