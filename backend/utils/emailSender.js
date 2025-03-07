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


// 📌 ✅ Function to send task email notification
export const sendTaskEmailNotifications = async (emails, task) => {
  try {
    const mailOptions = {
      from: process.env.SMTP_MAIL,
      to: emails, // Send to all gig workers
      subject: `New Task Available: ${task.title}`,
      html: `
        <h2>New Task Available</h2>
        <p><strong>Title:</strong> ${task.title}</p>
        <p><strong>Description:</strong> ${task.description}</p>
        <p><strong>Location:</strong> ${task.location}</p>
        <p><strong>Incentive:</strong> $${task.incentive.toFixed(2)}</p>
        <p><strong>Deadline:</strong> ${task.deadline ? task.deadline.toISOString().split("T")[0] : "No deadline"}</p>
        <br/>
        <p>Check the app for more details.</p>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log("📧 Task notification email sent to gig workers!");
  } catch (error) {
        console.error("Failed to send task email notification:", error);
    }
};

export const sendTaskEmailNotification = async (emails, task) => {
  try {
    const mailOptions = {
      from: process.env.SMTP_MAIL,
      to: emails, // Can be a single email or an array of emails
      subject: `New Task Assigned: ${task.title}`,
      html: `
        <h2>New Task Assigned</h2>
        <p><strong>Title:</strong> ${task.title}</p>
        <p><strong>Description:</strong> ${task.description}</p>
        <p><strong>Location:</strong> ${task.location}</p>
        <p><strong>Incentive:</strong> $${task.incentive.toFixed(2)}</p>
        <p><strong>Deadline:</strong> ${task.deadline ? task.deadline.toISOString().split("T")[0] : "No deadline"}</p>
        <br/>
        <p>Check the app for more details.</p>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log("📧 Task assignment email sent to worker!");
  } catch (error) {
    console.error("Failed to send task email notification:", error);
  }
};