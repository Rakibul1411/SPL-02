import mongoose from 'mongoose';
//import bcrypt from 'bcryptjs';
import bcrypt from 'bcrypt';

// Define the schema
const userSchema = new mongoose.Schema(
  {
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
        unique: true,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    role: {
        type: String,
        required: true
    },
    status: {
        type: String,
        required: true
    },
    isVerified: {
        type: Boolean,
        default: false // Defaults to false until OTP is verified
    },
    otp: {
        type: String
    },
    otpExpiry: {
        type: Date
    },
  }, 
  
  { timestamps: true }
  
);

const User = mongoose.model('User', userSchema);

// Export the model
export default User;