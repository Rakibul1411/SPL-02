import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import bodyParser from 'body-parser';
import path from 'path';
import { fileURLToPath } from 'url';


import authRoute from './routes/auth.js';
import taskRoute from './routes/task.js';
import profileRoute from './routes/profileRoute.js';
import reportRoute from './routes/report.js';
import dotenv from 'dotenv';


dotenv.config();

const app = express();


app.use(cors({
  origin: '*',
  methods: ['POST', 'PUT', 'GET', 'OPTIONS', 'HEAD'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


mongoose.connect(process.env.MONGO_URI, {

}).then(() => {
    console.log('Connected to MongoDB')

    // Routes
    app.use('/auth', authRoute);

    app.use('/task', taskRoute);

    app.use('/profile', profileRoute);

    app.use('/report', reportRoute);


    const PORT = process.env.PORT || 3005;
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on port ${PORT}`);
    });
}).catch((err) => {
    console.error('MongoDB connection error:', err)
});