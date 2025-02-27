import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import sequelize from './config/database';
import authRoutes from './routes/authRoutes';
import path from 'path';
import Message from './models/message'; // ✅ Import the Message model

dotenv.config();

const app = express();
const PORT = process.env.SERVER_PORT || 5000;
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));
app.use('/api/auth', authRoutes);

// ✅ Example optional route to fetch chat history
app.get('/api/messages/:senderId/:receiverId', async (req, res) => {
  const { senderId, receiverId } = req.params;
  try {
    const messages = await Message.findAll({
      where: {
        // Show all messages between these 2 users
        senderId: [senderId, receiverId],
        receiverId: [senderId, receiverId],
      },
      order: [['createdAt', 'ASC']],
    });
    res.json({ messages });
  } catch (error) {
    console.error('❌ Error fetching messages:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.get('/', (req, res) => {
  res.send('Server is running');
});

// ✅ (Optional) Track online users
const onlineUsers = new Map<string, string>();

io.on('connection', (socket) => {
  console.log('✅ A user connected:', socket.id);

  // 1) "join"
  socket.on('join', (userId: string) => {
    console.log(`🔗 ${userId} joined with socket ID: ${socket.id}`);
    socket.join(userId);
    onlineUsers.set(userId, socket.id);
  });

  // 2) "sendMessage"
  socket.on('sendMessage', async (data) => {
    // data = { senderId, receiverId, message, timestamp }
    console.log('📩 Message received:', data);

    try {
      // Save to DB
      const newMessage = await Message.create({
        senderId: data.senderId,
        receiverId: data.receiverId,
        messageType: 'text',
        content: data.message,
      });

      // Emit to the receiver's room
      io.to(data.receiverId).emit('receiveMessage', {
        ...data,
        createdAt: newMessage.createdAt,
      });
      console.log(`📤 Sent message to room: ${data.receiverId}`);
    } catch (error) {
      console.error('❌ Error saving message:', error);
    }
  });

  // 3) "disconnect"
  socket.on('disconnect', () => {
    console.log('❌ User disconnected:', socket.id);
    // Remove from onlineUsers map (optional)
    for (const [userId, sockId] of onlineUsers.entries()) {
      if (sockId === socket.id) {
        onlineUsers.delete(userId);
        break;
      }
    }
  });
});

const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connected successfully.');

    await sequelize.sync({ force: false });
    console.log('✅ Database tables synchronized.');

    server.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('❌ Unable to connect to the database:', error);
  }
};

startServer();
