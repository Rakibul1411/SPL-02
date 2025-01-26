import bcrypt from 'bcrypt';
//import bcrypt from 'bcryptjs';
import User from '../models/userTable.js';
import { generateOTP } from '../utils/otpGenerator.js';
import { sendOTP } from '../utils/emailSender.js';

// Registration function with OTP
export const registration = async (req, res) => {
  const { name, email, password, role } = req.body;

  try {

    // Check if email already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generate OTP
    const otp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // OTP expires in 10 minutes

    // Create a new user
    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      role,
      status: 'inactive', // User is inactive until OTP is verified
      otp,
      otpExpiry: otpExpires,
    });

    await newUser.save();

    // Send OTP to the user's email
    await sendOTP(email, otp);

    res.status(201).json({isRegistration: true, message: 'OTP sent to your email. Please verify to complete registration.' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to register user', details: error.message });
  }
};

// OTP verification for registration
export const verifyRegistrationOTP = async (req, res) => {
  const { email, otp } = req.body;

  console.log(req.body);

  try {
    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if OTP matches and is not expired
    if (user.otp !== otp || user.otpExpires < new Date()) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    // Mark user as verified and active
    user.isVerified = true;
    user.status = 'active';
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();

    res.status(200).json({ success: true, message: 'Registration successful. You can now login.' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to verify OTP', details: error.message });
  }
};



// Login function with OTP
export const login = async (req, res) => {
  const { email, password } = req.body;

  try {
    // Find user by email
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Compare passwords
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate OTP
    const otp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // OTP expires in 10 minutes

    // Save OTP and expiration time in the user document
    user.otp = otp;
    user.otpExpires = otpExpires;
    await user.save();

    // Send OTP to the user's email
    await sendOTP(email, otp);

    res.status(200).json({requiresOTP: true, role: user.role, message: 'OTP sent to your email. Please verify to login.' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to login', details: error.message });
  }
};

// OTP verification for login
export const verifyLoginOTP = async (req, res) => {
  const { email, otp } = req.body;

  console.log(req.body);

  try {
    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if OTP matches and is not expired
    if (user.otp !== otp || user.otpExpires < new Date()) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    // Clear OTP fields
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to verify OTP', details: error.message });
  }
};