import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';

// import homeRoute from './routes/home.js';
import authRouter from './routes/auth.js';
 //import loginRoute from './routes/login.js';

const app = express();

app.use(cors()); // Middleware to enable CORS
app.use(express.json()); // Middleware to parse JSON requests

// Connect to MongoDB
mongoose.connect('mongodb+srv://mdrakibul11611:rakibul11611@cluster0.4rzyv.mongodb.net/spldb', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
}).then(() => {
    console.log('Connected to MongoDB');

    // Routes
    // app.use('/', homeRoute);
    app.use('/insight', authRouter);
    // app.use('/', loginRoute);

    app.listen(3003, () => {
        console.log('Server is running on port 3003');
    });
}).catch((error) => {
    console.error('Error connecting to MongoDB:', error.message);
});