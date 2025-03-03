import express from "express";
import http from "http";
import { Server } from "socket.io";
import dotenv from "dotenv";
import sequelize from "./config/database";
import authRoutes from "./routes/authRoutes";
import path from "path";
import mediaRoutes from "./routes/mediaRoutes";
import messageRoutes from "./routes/mediaRoutes";

import Message from "./models/message";
import User from "./models/user"; // ✅ Import the User model
import Media from "./models/media"; // ✅ Import the User model

import GroupMessage from "./models/groupMessage"; // ✅ Group chat model
import groupRoutes from "./routes/groupRoutes";
// (Optional) If you have groupMessage routes, import them too.

dotenv.config();

const app = express();
const PORT = process.env.SERVER_PORT || 5000;
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

// ===== Middleware & Routes =====
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));
app.use("/api/auth", authRoutes);
app.use("/api/groups", groupRoutes);
app.use("/api/media", mediaRoutes);
app.use("/api/messages", messageRoutes);

// (Optional) app.use("/api/groups", groupMessageRoutes);

// ===== Example route: fetch 1:1 chat history =====
app.get("/api/messages/:senderId/:receiverId", async (req, res) => {
  const { senderId, receiverId } = req.params;
  try {
    const messages = await Message.findAll({
      where: {
        // Show all messages between these 2 users
        senderId: [senderId, receiverId],
        receiverId: [senderId, receiverId],
      },
      order: [["createdAt", "ASC"]],
    });
    res.json({ messages });
  } catch (error) {
    console.error("❌ Error fetching messages:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

app.get("/", (req, res) => {
  res.send("Server is running");
});

// ===== Track Online Users (Optional) =====
const onlineUsers = new Map<string, string>();

// ===== Socket.IO Logic =====
io.on("connection", (socket) => {
  console.log("✅ A user connected:", socket.id);

  // ===== A) "join" personal & group rooms =====
  // data = { userId: "xyz123", groupIds: ["gid1", "gid2", ...] }
  socket.on("join", (data: { userId: string; groupIds?: string[] }) => {
    const { userId, groupIds } = data; // ✅ Move destructuring to the top

    onlineUsers.set(userId, socket.id);

    // ✅ Notify all clients that this user is online
    io.emit("userOnline", { userId });

    console.log(`🔵 ${userId} is now online with socket ID: ${socket.id}`);

    // ✅ Send updated list of online users to the joining user
    io.to(socket.id).emit("onlineUsers", Array.from(onlineUsers.keys()));

    console.log(`🔗 ${userId} joined with socket ID: ${socket.id}`);

    // 1) Join personal room
    socket.join(userId);

    // 2) Also join each group room if needed
    if (groupIds && groupIds.length > 0) {
      groupIds.forEach((groupId) => {
        socket.join(groupId);
        console.log(`🔗 ${userId} also joined group room: ${groupId}`);
      });
    }
  });

  // ===== B) Direct Message Event (1-to-1) =====
  socket.on("sendMessage", async (data) => {
    console.log("📩 Message received:", data);

    try {
      let newMessage;
      if (data.mediaUrl) {
        // Media message
        newMessage = await Message.create({
          senderId: data.senderId,
          receiverId: data.receiverId,
          messageType: data.mediaType, // 'image' | 'video'
          content: data.mediaUrl, // Store URL
        });

        // Save media to DB
        await Media.create({
          userId: data.senderId,
          messageId: newMessage.id,
          mediaType: data.mediaType,
          mediaUrl: data.mediaUrl,
        });
      } else {
        // Text message
        newMessage = await Message.create({
          senderId: data.senderId,
          receiverId: data.receiverId,
          messageType: "text",
          content: data.message,
        });
      }

      // Emit message to receiver
      io.to(data.receiverId).emit("receiveMessage", {
        id: newMessage.id,
        senderId: data.senderId,
        receiverId: data.receiverId,
        messageType: data.mediaType || "text",
        content: data.mediaUrl || data.message,
        createdAt: newMessage.createdAt,
      });

      console.log(`📤 Sent message to ${data.receiverId}`);
    } catch (error) {
      console.error("❌ Error sending message:", error);
    }
  });

  // ===== C) Group Message Event =====
  // ===== C) Group Message Event =====
  socket.on("sendGroupMessage", async (groupData) => {
    console.log("👥 Group message received:", groupData);

    try {
      // ✅ Fetch user details from DB
      const sender = await User.findByPk(groupData.senderId, {
        attributes: ["id", "username", "profilePicture"],
      });

      if (!sender) {
        console.error("❌ User not found:", groupData.senderId);
        return;
      }

      // ✅ Save message in DB
      const newGroupMsg = await GroupMessage.create({
        senderId: groupData.senderId,
        groupId: groupData.groupId,
        messageType: "text",
        content: groupData.content,
      });

      // ✅ Broadcast message with full user details
      const messageData = {
        id: newGroupMsg.id,
        senderId: sender.id,
        senderName: sender.username, // ✅ Include sender name
        senderProfilePic: sender.profilePicture, // ✅ Include profile pic
        groupId: groupData.groupId,
        content: groupData.content,
        createdAt: newGroupMsg.createdAt,
      };

      io.to(groupData.groupId).emit("receiveGroupMessage", messageData);
      console.log(`📤 Sent group message to room: ${groupData.groupId}`);
    } catch (error) {
      console.error("❌ Error saving group message:", error);
    }
  });

  // ===== D) "disconnect" =====
  socket.on("disconnect", () => {
    console.log("❌ User disconnected:", socket.id);

    for (const [userId, sockId] of onlineUsers.entries()) {
      if (sockId === socket.id) {
        onlineUsers.delete(userId);

        // ✅ Notify all clients that this user is now offline
        io.emit("userOffline", { userId });

        console.log(`⚫ ${userId} is now offline`);
        break;
      }
    }
  });

  // In server.ts, inside io.on("connection", (socket) => { ... })

  socket.on("joinGroup", (data: { groupId: string }) => {
    const { groupId } = data;
    socket.join(groupId);
    console.log(`🔗 Socket ${socket.id} joined new group room: ${groupId}`);
  });
});

// ===== Start Server & Sync DB =====
const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log("✅ Database connected successfully.");

    await sequelize.sync({ force: false });
    console.log("✅ Database tables synchronized.");

    server.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("❌ Unable to connect to the database:", error);
  }
};

startServer();
