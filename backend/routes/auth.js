import express from 'express';
import {
  registration,
  verifyRegistrationOTP,
  login,
  verifyLoginOTP,
} from '../controller/authController.js';

const router = express.Router();

// Registration routes
router.post('/registration', registration);
router.post('/verify-registration-otp', verifyRegistrationOTP);

// Login routes
router.post('/login', login);
router.post('/verify-login-otp', verifyLoginOTP);

export default router;