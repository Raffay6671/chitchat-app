import express, { Request, Response, NextFunction } from "express";
import multer from "multer";
import path from "path";
import { v4 as uuidv4 } from "uuid";
import Media from "../models/media";
import Message from "../models/message";

const router = express.Router();

// ✅ Set up Multer Storage for Uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, "../../uploads/media")); // Save to 'uploads/media/'
  },
  filename: (req, file, cb) => {
    cb(null, `${uuidv4()}${path.extname(file.originalname)}`);
  },
});

// ✅ Multer Middleware
const upload = multer({ storage });

// ✅ Fix: Ensure Express handles async functions properly
router.post(
  "/upload",
  upload.single("file"),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { userId, messageId, mediaType } = req.body;

      // ✅ Ensure file exists
      if (!req.file) {
        res.status(400).json({ message: "No file uploaded." });
        return;
      }

      const mediaUrl = `/uploads/media/${req.file.filename}`;

      // ✅ Save media reference in the database
      await Media.create({
        userId,
        messageId,
        mediaType,
        mediaUrl,
      });

      // ✅ Always return a response
      res
        .status(201)
        .json({ message: "Media uploaded successfully", mediaUrl });
    } catch (error) {
      console.error("❌ Error uploading media:", error);
      next(error); // ✅ Pass error to Express error handler
    }
  }
);

// Endpoint to create a message record
router.post("/create", async (req, res) => {
  const { senderId, receiverId, messageType, content } = req.body;
  try {
    const newMessage = await Message.create({
      senderId,
      receiverId,
      messageType,
      content,
    });
    res.status(201).json({ messageId: newMessage.id });
  } catch (error) {
    console.error("❌ Error creating message:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

export default router;
