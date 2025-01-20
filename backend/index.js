import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import bodyParser from 'body-parser';

// import homeRoute from './routes/home.js';
import authRoute from './routes/auth.js';
import taskRoute from './routes/task.js';
 //import loginRoute from './routes/login.js';

const app = express();

app.use(cors()); // Middleware to enable CORS
app.use(express.json()); // Middleware to parse JSON requests
app.use(express.urlencoded({ extended: true })); // is part of an Express.js application and is used to configure middleware for parsing incoming requests with URL-encoded payloads

// Connect to MongoDB
mongoose.connect('mongodb+srv://mdrakibul11611:rakibul11611@cluster0.4rzyv.mongodb.net/sqldb', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
}).then(() => {     
    console.log('Connected to MongoDB');

    // Routes
    app.use('/auth', authRoute);

    app.use('/task', taskRoute);

    app.listen(3003, () => {
        console.log('Server is running on port 3003');
    });
}).catch((error) => {
    console.error('Error connecting to MongoDB:', error.message);
});