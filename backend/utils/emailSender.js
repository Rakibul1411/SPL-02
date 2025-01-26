import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Create a transporter object
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: false,
  auth: {
    user: process.env.SMTP_MAIL, // Your email address
    pass: process.env.SMTP_PASSWORD, // Your email password or app-specific password
  },
});

// Function to send OTP
export const sendOTP = async (email, otp) => {
  try {
    const mailOptions = {
      from: process.env.SMTP_MAIL,
      to: email,
      subject: 'OTP for Verification',
      text: `Your OTP for verification is: ${otp}\nIt will expire in 10 minutes.`,
    };

    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error('Failed to send OTP:', error);
    throw new Error('Failed to send OTP');
  }
};