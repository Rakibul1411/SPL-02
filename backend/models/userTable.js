import mongoose from 'mongoose';
//import bcrypt from 'bcryptjs';
import bcrypt from 'bcrypt';

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
        default: false
    },
    otp: {
        type: String
    },
    otpExpiry: {
        type: Date
    },
    latitude: {
        type: Number,
        required: true
    },
    longitude: {
        type: Number,
        required: true
    }
  },
  { timestamps: true }
);

const User = mongoose.model('User', userSchema);

// Export the model
export default User;