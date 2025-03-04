import User from '../models/userTable.js';

export const getProfile = async (req, res) => {
  try {
    // Extract email from path parameters
    const email = req.params.email;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    // Fetch user data from the database using email
    const user = await User.findOne({ email: email });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Return user profile data in JSON format
    res.status(200).json({
      name: user.name,
      email: user.email,
      role: user.role,
      isVerified: user.isVerified,
    });
  } catch (error) {
    // Handle unexpected errors
    console.error('Error fetching profile:', error);
    res.status(500).json({ message: 'Failed to fetch profile data', error: error.message });
  }
};