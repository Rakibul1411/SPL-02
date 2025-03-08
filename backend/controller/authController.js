import bcrypt from 'bcrypt';
import User from '../models/userTable.js';
import { generateOTP } from '../utils/otpGenerator.js';
import { sendOTP } from '../utils/emailSender.js';

export const registration = async (req, res) => {
  const { name, email, password, role, latitude, longitude } = req.body;
  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    let finalName = name;

    if (role === 'Shop Manager') {
      const similarNameUsers = await User.find({
        role: 'Shop Manager',
        name: new RegExp(`^${name}(-\\d+)?$`)
      });

      if (similarNameUsers.length > 0) {
        const baseNamePattern = new RegExp(`^(${name})-\\d+$`);
        const existingNumbers = similarNameUsers
          .map(user => {
            const match = user.name.match(baseNamePattern);
            if (match) {
              return parseInt(user.name.split('-').pop(), 10);
            }
            return 0;
          })
          .filter(num => !isNaN(num));

        // Find the highest number and add 1
        const highestNumber = existingNumbers.length > 0 ?
          Math.max(...existingNumbers) : 0;

        finalName = `${name}-${highestNumber + 1}`;
      } else {
        // First shop manager with this name, no need to modify
        finalName = `${name}-1`;
      }
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const otp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000);
    const newUser = new User({
      name: finalName,
      email,
      password: hashedPassword,
      role,
      status: 'inactive',
      otp,
      otpExpiry: otpExpires,
      latitude,
      longitude,
    });
    await newUser.save();
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

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate OTP
    const otp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000);

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

export const resendOTP = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Generate a new OTP
    const otp = generateOTP();
    user.otp = otp;
    user.otpExpires = new Date(Date.now() + 10 * 60 * 1000);
    await user.save();

    // Send the new OTP
    await sendOTP(email, otp);

    res.status(200).json({ message: 'A new OTP has been sent to your email' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to resend OTP', details: error.message });
  }
};

export const sendOtpForPasswordReset = async (req, res) => {
  const { email } = req.body;

  try {
    // Check if the user exists
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'User does not exist' });
    }

    // Generate a new OTP
    const otp = generateOTP();
    user.otp = otp;
    user.otpExpires = new Date(Date.now() + 10 * 60 * 1000); // OTP expires in 10 minutes
    await user.save();

    // Send the OTP to the user's email
    await sendOTP(email, otp);

    res.status(200).json({ message: 'OTP has been sent to your email' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to send OTP', details: error.message });
  }
};


// Password reset: verify OTP
export const verifyPasswordResetOTP = async (req, res) => {
  const { email, otp } = req.body;

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

    // OTP is valid, allow user to reset password
    res.status(200).json({ message: 'OTP verified successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to verify OTP', details: error.message });
  }
};

// Password reset function: reset the password
export const resetPassword = async (req, res) => {
  const { email, newPassword, otp } = req.body;

  try {
    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Hash the new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update the user's password
    user.password = hashedPassword;
    user.otp = undefined; // Clear OTP as it has been used
    user.otpExpires = undefined; // Clear OTP expiration
    await user.save();

    res.status(200).json({ message: 'Password has been successfully reset' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to reset password', details: error.message });
  }
};

// Add this to your authController.js
export const updatePassword = async (req, res) => {
  const { email, currentPassword, newPassword } = req.body;

  console.log(newPassword);

  try {
    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if current password matches
    const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Current password is incorrect' });
    }

    // Hash the new password and update
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;

    await user.save();

    console.log('Password updated successfully')

    res.status(200).json({ message: 'Password updated successfully' });
    console.log('Password updated successfully');
  } catch (error) {
    res.status(500).json({ error: 'Failed to update password', details: error.message });
  }
};



