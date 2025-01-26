import express from 'express';
import { getProfile } from '../controller/profileController.js'

const router = express.Router();

// Profile route
router.get('/profile', getProfile);

export default router;