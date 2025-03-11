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
export const sendTaskEmailNotification = async (emails, task, taskAssigned) => {
  try {
    const mailOptions = {
      from: process.env.SMTP_MAIL,
      to: emails,
      subject: `New Task Assigned: ${task.title}`,
      html: `
        <html>
          <head>
            <style>
              body {
                font-family: Arial, sans-serif;
                margin: 0;
                padding: 0;
                background-color: #f4f7fc;
                color: #333;
              }
              .container {
                max-width: 600px;
                margin: 20px auto;
                padding: 20px;
                background-color: #ffffff;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
              }
              h2 {
                text-align: center;
                color: #2a3d7f;
              }
              .task-details {
                margin: 20px 0;
              }
              .task-details p {
                font-size: 16px;
                line-height: 1.6;
                margin-bottom: 8px;
              }
              .task-details strong {
                font-weight: bold;
                color: #444;
              }
              .task-location {
                margin-top: 15px;
                background-color: #f9f9f9;
                padding: 10px;
                border-radius: 5px;
              }
              .task-location p {
                margin: 5px 0;
              }
              .task-incentive-code {
                font-size: 18px;
                color: #28a745;
                font-weight: bold;
              }
              .task-deadline {
                font-size: 14px;
                color: #ff6f61;
              }
              .cta {
                background-color: #e53935; /* Red background */
                color: white; /* White text */
                font-weight: bold; /* Bold text */
                padding: 15px;
                text-align: center;
                margin-top: 20px;
                border-radius: 5px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <h2>New Task Assigned</h2>

              <div class="task-details">
                <p><strong>Title:</strong> ${task.title}</p>
                <p><strong>Description:</strong> ${task.description}</p>

                <div class="task-location">
                  <p><strong>Location:</strong></p>
                  <p><strong>Latitude:</strong> ${task.latitude}</p>
                  <p><strong>Longitude:</strong> ${task.longitude}</p>
                </div>

                <p class="task-incentive-code"><strong>Incentive:</strong> $${task.incentive.toFixed(2)}</p>
                <p class="task-deadline"><strong>Deadline:</strong> ${task.deadline ? task.deadline.toISOString().split("T")[0] : "No deadline"}</p>
                <p class="task-incentive-code"><strong>Verification Code For Worker:</strong> ${taskAssigned.verificationCode}</p>
              </div>

              <div class="cta">
                <p>Check the app for more details.</p>
              </div>
            </div>
          </body>
        </html>
      `,
    };
    await transporter.sendMail(mailOptions);
    console.log("📧 Task notification email sent to gig workers!");
  } catch (error) {
        console.error("Failed to send task email notification:", error);
    }
};

export const sendTaskEmailNotifications = async (emails, task) => {
  try {
    const mailOptions = {
      from: process.env.SMTP_MAIL,
      to: emails, // Send to all gig workers
      subject: `New Task Available: ${task.title}`,
      html: `
        <html>
          <head>
            <style>
              body {
                font-family: Arial, sans-serif;
                margin: 0;
                padding: 0;
                background-color: #f4f7fc;
                color: #333;
              }
              .container {
                max-width: 600px;
                margin: 20px auto;
                padding: 20px;
                background-color: #ffffff;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
              }
              h2 {
                text-align: center;
                color: #2a3d7f;
              }
              .task-details {
                margin: 20px 0;
              }
              .task-details p {
                font-size: 16px;
                line-height: 1.6;
                margin-bottom: 8px;
              }
              .task-details strong {
                font-weight: bold;
                color: #444;
              }
              .task-location {
                margin-top: 15px;
                background-color: #f9f9f9;
                padding: 10px;
                border-radius: 5px;
              }
              .task-location p {
                margin: 5px 0;
              }
              .task-incentive {
                font-size: 18px;
                color: #28a745;
                font-weight: bold;
              }
              .task-deadline {
                font-size: 14px;
                color: #ff6f61;
              }
              .cta {
                background-color: #e53935; /* Red background */
                color: white; /* White text */
                font-weight: bold; /* Bold text */
                padding: 15px;
                text-align: center;
                margin-top: 20px;
                border-radius: 5px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <h2>New Task Available</h2>

              <div class="task-details">
                <p><strong>Title:</strong> ${task.title}</p>
                <p><strong>Description:</strong> ${task.description}</p>

                <div class="task-location">
                  <p><strong>Location:</strong></p>
                  <p><strong>Latitude:</strong> ${task.latitude}</p>
                  <p><strong>Longitude:</strong> ${task.longitude}</p>
                </div>

                <p class="task-incentive"><strong>Incentive:</strong> $${task.incentive.toFixed(2)}</p>
                <p class="task-deadline"><strong>Deadline:</strong> ${task.deadline ? task.deadline.toISOString().split("T")[0] : "No deadline"}</p>
              </div>

              <div class="cta">
                <p>Check the app for more details.</p>
              </div>
            </div>
          </body>
        </html>
      `,
    };
    await transporter.sendMail(mailOptions);
    console.log("📧 Task assignment email sent to worker!");
  } catch (error) {
    console.error("Failed to send task email notification:", error);
  }
};