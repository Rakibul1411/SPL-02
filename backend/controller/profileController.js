// Import necessary modules
import User from '../models/userTable.js';
import jwt from 'jsonwebtoken';

// Fetch user profile data
export const getProfile = async (req, res) => {
  try {
    // Extract token from headers
    const token = req.headers.authorization.split(' ')[1];
    
    // Verify token
    const decoded = jwt.verify(token, 'YOUR_SECRET_KEY'); // Replace with your secret key
    
    // Fetch user data from database
    const user = await User.findById(decoded.userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Return user profile data
    res.status(200).json({
      name: user.name,
      email: user.email,
      phone: user.phone,
      location: user.location,
    });
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch profile data', error: error.message });
  }
};