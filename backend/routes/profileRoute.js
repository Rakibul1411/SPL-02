import express from 'express';
import { getProfile, updateProfile } from '../controller/profileController.js';

const router = express.Router();

// Changed to use query parameter instead of path parameter
router.get('/getProfile/:email', getProfile);

// Update user profile
router.put('/updateProfile', updateProfile);

export default router;