import express from 'express';
import dotenv from 'dotenv';
import sequelize from './config/database';
import authRoutes from './routes/authRoutes';
import path from 'path';

dotenv.config();

const app = express();
const PORT = process.env.SERVER_PORT || 5000;

// Middleware to parse JSON
app.use(express.json());

// ✅ Serve static files from the uploads folder
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// ✅ Use the auth routes
app.use('/api/auth', authRoutes);

// ✅ Server and DB Connection
const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connected successfully.');

    await sequelize.sync({ force: false });
    console.log('✅ Database tables synchronized.');

    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('❌ Unable to connect to the database:', error);
  }
};

startServer();
