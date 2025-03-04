import express from 'express';
import { getProfile } from '../controller/profileController.js';

const router = express.Router();

// Changed to use query parameter instead of path parameter
router.get('/getProfile/:email', getProfile);

export default router;