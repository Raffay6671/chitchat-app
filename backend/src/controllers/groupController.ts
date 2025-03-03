import { Request, Response } from "express";
import { Group, GroupMember, User, GroupMessage } from "../models";
import { v4 as uuidv4 } from "uuid";

/**
 * CREATE A NEW GROUP
 * Endpoint: POST /api/groups
 * Body: { name: string, members: string[] }
 */
export const createGroup = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { name, members } = req.body;
    const userId = (req as any).user.id;

    if (!name || !Array.isArray(members) || members.length < 1) {
      res.status(400).json({
        message: "Group name and at least 1 member are required.",
      });
      return;
    }

    // 1) Create the Group
    const newGroup = await Group.create({
      id: uuidv4(),
      name,
    });

    // 2) Add the group creator
    await GroupMember.create({
      groupId: newGroup.id,
      userId: userId,
    });

    // 3) Add invited members
    const distinctMembers = [...new Set(members)];
    const memberRecords = distinctMembers.map((memberId: string) => ({
      groupId: newGroup.id,
      userId: memberId,
    }));
    await GroupMember.bulkCreate(memberRecords);

    // 4) Re-fetch with associated members
    const createdGroupWithMembers = await Group.findOne({
      where: { id: newGroup.id },
      include: [
        {
          model: User,
          as: "groupUsers",
          attributes: [
            "id",
            "username",
            "email",
            "displayName",
            "profilePicture",
          ],
          through: { attributes: [] },
        },
      ],
    });

    res.status(201).json({
      message: `Group '${name}' created successfully!`,
      group: createdGroupWithMembers,
    });
  } catch (error) {
    console.error("❌ Error creating group:", error);
    res.status(500).json({ message: "Server error creating group." });
  }
};

/**
 * GET ALL GROUPS FOR THE LOGGED-IN USER
 * Endpoint: GET /api/groups
 */
export const getGroups = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.id;
    const memberships = await GroupMember.findAll({
      where: { userId },
      attributes: ["groupId"],
    });

    const groupIds = memberships.map((m) => m.groupId);

    const groups = await Group.findAll({
      where: { id: groupIds },
      attributes: ["id", "name", "createdAt", "updatedAt"],
      include: [
        {
          model: User,
          as: "groupUsers",
          attributes: ["id", "username", "displayName", "profilePicture"],
          through: { attributes: [] },
        },
      ],
    });

    res.status(200).json({ groups });
  } catch (error) {
    console.error("❌ Error fetching groups:", error);
    res.status(500).json({ message: "Server error fetching groups." });
  }
};

/**
 * GET GROUP MESSAGES
 * Endpoint: GET /api/groups/:groupId/messages
 */
export const getGroupMessages = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { groupId } = req.params;
    const userId = (req as any).user.id;

    // ✅ Ensure user is a member of the group
    const isMember = await GroupMember.findOne({
      where: { groupId, userId },
    });

    if (!isMember) {
      res.status(403).json({ message: "You are not a member of this group" });
      return;
    }

    // ✅ Fetch messages with sender details (Alias must match models/index.ts)
    const messages = await GroupMessage.findAll({
      where: { groupId },
      include: [
        {
          model: User,
          as: "sender", // ✅ Must match alias in models/index.ts
          attributes: ["id", "username", "profilePicture"],
        },
      ],
      order: [["createdAt", "ASC"]],
    });

    // ✅ Format messages for frontend
    const formattedMessages = messages.map((msg) => ({
      id: msg.id,
      senderId: msg.senderId,
      senderName: msg.sender?.username || "Unknown",
      senderProfilePic:
        msg.sender?.profilePicture || "https://via.placeholder.com/40",
      groupId: msg.groupId,
      messageType: msg.messageType,
      content: msg.content,
      createdAt: msg.createdAt,
    }));

    res.status(200).json({ messages: formattedMessages });

    return; // ✅ Ensure function always returns void
  } catch (error) {
    console.error("❌ Error fetching group messages:", error);
    res.status(500).json({ message: "Server error fetching group messages." });
    return;
  }
};
