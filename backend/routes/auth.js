import express from 'express';
import {
  registration,
  verifyRegistrationOTP,
  login,
  verifyLoginOTP,
  resendOTP,
  sendOtpForPasswordReset,
  verifyPasswordResetOTP,
  resetPassword,
  updatePassword
} from '../controller/authController.js';

const router = express.Router();

// Registration routes
router.post('/registration', registration);
router.post('/verify-registration-otp', verifyRegistrationOTP);

// Login routes
router.post('/login', login);
router.post('/verify-login-otp', verifyLoginOTP);

// Resend OTP
router.post('/resend-otp', resendOTP);

// Password Reset routes
router.post('/send-password-reset-otp', sendOtpForPasswordReset);
router.post('/verify-password-reset-otp', verifyPasswordResetOTP);
router.post('/reset-password', resetPassword);

// Add this to your routes in auth.js
router.post('/update-password', updatePassword);


export default router;