import express from 'express';
import { getProfile, updateProfile, getUserByEmail, getUserByRole } from '../controller/profileController.js';

const router = express.Router();

// Changed to use query parameter instead of path parameter
router.get('/getProfile/:email', getProfile);

// Update user profile
router.put('/updateProfile', updateProfile);

// Route to fetch user by email
router.get('/email/:email', getUserByEmail);

router.get('/getUserByRole', getUserByRole);

export default router;