const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
  companyId: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  location: { type: String, required: true },
  incentive: { type: Number, required: true },
  deadline: { type: Date, required: true },
  status: { type: String, enum: ['CREATED', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED'], default: 'CREATED' },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

const NotificationSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  message: { type: String, required: true },
  type: { type: String, enum: ['TASK_CREATED', 'TASK_ASSIGNED', 'TASK_COMPLETED', 'PAYMENT_PROCESSED', 'SYSTEM_UPDATE'], required: true },
  sendAt: { type: Date, default: Date.now },
  read: { type: Boolean, default: false },
});

const Task = mongoose.model('Task', TaskSchema);
const Notification = mongoose.model('Notification', NotificationSchema);

module.exports = { Task, Notification };
