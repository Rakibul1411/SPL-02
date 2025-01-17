import bcrypt from 'bcrypt';
import User from '../src/models/userTable.js';


//registration function
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

    // Create a new user
    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      role,
      status: 'active',
    });

    await newUser.save();
    res.status(201).json({ message: 'User registered successfully' });
  } 
  catch (error) {
    res.status(500).json({ error: 'Failed to register user', details: error.message });
  }
};



//log in function
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

      res.status(200).json({ message: 'Login successful', user: { name: user.name, email: user.email } });
  } 
  catch (error) {
      res.status(500).json({ error: 'Failed to login', details: error.message });
  }
}