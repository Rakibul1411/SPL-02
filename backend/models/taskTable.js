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
      enum: ['pending', 'finished', 'deadline_passed'],
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
    selectedWorkers: [{
      workerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
      },
      email: {
        type: String,
        required: true
      },
      distance: {
        type: Number,
        required: true
      }
    }],
    acceptedByWorkers: [{
      workerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
      },
      email: {
        type: String,
        required: true
      },
    }],
    rejectedByWorkers: [{
      workerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
      },
      email: {
        type: String,
        required: true
      },
    }],
    isAssigned: {
      type: Boolean,
      default: false
    }
  },
  { timestamps: true }
);

const Task = mongoose.model('Task', taskSchema);

export default Task;