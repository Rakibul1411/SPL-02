import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import bodyParser from 'body-parser';
import path from 'path';
import { fileURLToPath } from 'url';

// import homeRoute from './routes/home.js';
import authRoute from './routes/auth.js';
import taskRoute from './routes/task.js';
import profileRoute from './routes/profileRoute.js';
import reportRoute from './routes/report.js';
import dotenv from 'dotenv';

// Task Assignment_test
import { createServer } from "http";
import { initSocket } from "./socket/socket.js";
import taskRouteTest from './routes/taskRoute_test.js';

// Get __dirname equivalent in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();

const app = express();
// Task Assignment_test
const server = createServer(app);

// 🔥 CORS configuration goes here (BEFORE routes)
app.use(cors({
  origin: '*',
  methods: ['POST', 'PUT', 'GET', 'OPTIONS', 'HEAD', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json()); // Middleware to parse JSON requests
app.use(express.urlencoded({ extended: true })); // is part of an Express.js application and is used to configure middleware for parsing incoming requests with URL-encoded payloads

// Serve static files from the 'uploads' directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
//    useNewUrlParser: true,
//    useUnifiedTopology: true,
}).then(() => {
    console.log('✅ Connected to MongoDB')

    // Routes
    app.use('/auth', authRoute);

    app.use('/task', taskRoute);

    app.use('/profile', profileRoute);

    app.use('/report', reportRoute);

    // Task Assignment_test
    app.use("/task_test", taskRouteTest);

    // Start server
    const PORT = process.env.PORT || 3005;
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on port ${PORT}`);
    });
}).catch((err) => {
    console.error('❌ MongoDB connection error:', err)
});

// Task Assignment_test
// Initialize WebSocket
initSocket(server);