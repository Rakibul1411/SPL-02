import mongoose from 'mongoose';

const taskAssignmentSchema = new mongoose.Schema({
  task_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Task',
    required: true,
  },
  worker_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  shop_id: {
    type: String,
    required: true,
  },
  assignedAt: {
    type: Date,
    default: Date.now,
  },
  status: {
    type: String,
    enum: ['assigned', 'completed'],
    default: 'assigned',
  },
  verificationCode: {
    type: String,
    default: null,
  },
  verifiedAt: {
    type: Date,
    default: null,
  },
});

const TaskAssignment = mongoose.model('TaskAssignment', taskAssignmentSchema);

export default TaskAssignment;