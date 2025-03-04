import bcrypt from "bcrypt";
import User from "../models/userTable.js";
import { generateOTP } from "../utils/otpGenerator.js";
import { sendOTP } from "../utils/emailSender.js";

// 📌 ✅ Registration Function (OTP Verification Still Required)
export const registration = async (req, res) => {
  const { name, email, password, role } = req.body;

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already registered" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    // Generate OTP for registration
    const otp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // Expires in 10 minutes

    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      role,
      status: "inactive", // User remains inactive until OTP verification
      otp,
      otpExpiry: otpExpires,
    });

    await newUser.save();
    await sendOTP(email, otp); // Send OTP to email

    res.status(201).json({
      isRegistration: true,
      message: "OTP sent to your email. Please verify to complete registration.",
    });
  } catch (error) {
    res.status(500).json({ error: "Failed to register user", details: error.message });
  }
};

// 📌 ✅ Verify Registration OTP
export const verifyRegistrationOTP = async (req, res) => {
  const { email, otp } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (user.otp !== otp || user.otpExpires < new Date()) {
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }

    user.isVerified = true;
    user.status = "active";
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();

    res.status(200).json({ success: true, message: "Registration successful. You can now login." });
  } catch (error) {
    res.status(500).json({ error: "Failed to verify OTP", details: error.message });
  }
};

// 📌 ✅ Login Without OTP Verification
export const login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    res.status(200).json({
      success: true,
      message: "Login successful",
      user: {
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    res.status(500).json({ error: "Failed to login", details: error.message });
  }
};

// 📌 ✅ Resend OTP (For Registration & Password Reset)
export const resendOTP = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const otp = generateOTP();
    user.otp = otp;
    user.otpExpires = new Date(Date.now() + 10 * 60 * 1000);
    await user.save();

    await sendOTP(email, otp);

    res.status(200).json({ message: "A new OTP has been sent to your email" });
  } catch (error) {
    res.status(500).json({ error: "Failed to resend OTP", details: error.message });
  }
};

// 📌 ✅ Send OTP for Password Reset
export const sendOtpForPasswordReset = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User does not exist" });
    }

    const otp = generateOTP();
    user.otp = otp;
    user.otpExpires = new Date(Date.now() + 10 * 60 * 1000);
    await user.save();

    await sendOTP(email, otp);

    res.status(200).json({ message: "OTP has been sent to your email" });
  } catch (error) {
    res.status(500).json({ error: "Failed to send OTP", details: error.message });
  }
};

// 📌 ✅ Verify OTP for Password Reset
export const verifyPasswordResetOTP = async (req, res) => {
  const { email, otp } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (user.otp !== otp || user.otpExpires < new Date()) {
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }

    res.status(200).json({ message: "OTP verified successfully" });
  } catch (error) {
    res.status(500).json({ error: "Failed to verify OTP", details: error.message });
  }
};

// 📌 ✅ Reset Password After OTP Verification
export const resetPassword = async (req, res) => {
  const { email, newPassword } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();

    res.status(200).json({ message: "Password has been successfully reset" });
  } catch (error) {
    res.status(500).json({ error: "Failed to reset password", details: error.message });
  }
};
