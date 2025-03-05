import mongoose from 'mongoose';

const taskSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
    },
    companyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    shopName: {
      type: String,
      required: true,
    },
    incentive: {
      type: Number,
      required: true,
    },
    deadline: {
      type: Date,
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'in_progress', 'finished', 'deadline_passed'],
      default: 'pending',
    },
    latitude: {
      type: Number,
      required: true,
    },
    longitude: {
      type: Number,
      required: true,
    },
    selectedWorker: {
      type: Map,
      of: Number,
    },
    acceptedWorker: {
      type: Map, // Key-value pair: workerId -> distance
      of: Number, // Value is a number (distance)
      default: {}, // Default to an empty map
    },
    rejectedWorker: {
      type: Map, // Key-value pair: workerId -> distance
      of: Number, // Value is a number (distance)
      default: {}, // Default to an empty map
    },
  },
  { timestamps: true }
);

const Task = mongoose.model('Task', taskSchema);

export default Task;