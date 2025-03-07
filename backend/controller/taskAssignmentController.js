import Task from '../models/taskTable.js';
import User from "../models/userTable.js";
import TaskAssignment from '../models/taskAssignmentTable.js'; // Corrected import statement
import { sendTaskEmailNotification } from "../utils/emailSender.js"; // Import email function

// Assign a worker to a task
export const assignWorker = async (req, res) => {
  try {
    const { taskId, email } = req.params;
    console.log(email);

    // Find the task by ID
    const task = await Task.findById(taskId);
    if (!task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    // Find the worker by email
    const worker = await User.findOne({ email: email }); // Find worker by email
    if (!worker) {
      return res.status(404).json({ error: 'Worker not found' });
    }

    // Create a new task assignment
    const newAssignment = new TaskAssignment({
      task_id: taskId,
      worker_id: worker._id, // Use the worker's ID
      shop_id: task.shopName, // Assuming the task has a shopId field
      status: 'assigned',
      verificationCode: Math.random().toString(36).substring(2, 8), // Generate a random verification code
    });

    await newAssignment.save();

    // Update the task's assignedWorker field
    task.assignedWorker = worker._id;
    await task.save();

    // Send email notification to the worker
    await sendTaskEmailNotification([email], task);

    res.status(200).json({ message: 'Worker assigned successfully', task, assignment: newAssignment });
  } catch (err) {
    console.error('Error assigning worker:', err);
    res.status(500).json({ error: err.message });
  }
};

export const fetchAssignedTasks = async (req, res) => {
  try {
    const { workerId } = req.params;

    const taskAssignments = await TaskAssignment.find({ worker_id: workerId });

    if (!taskAssignments || taskAssignments.length === 0) {
      return res.status(200).json([]);
    }

    const tasksWithDetails = await Promise.all(
      taskAssignments.map(async (assignment) => {
        const task = await Task.findById(assignment.task_id);
        return {
          assignmentId: assignment._id,
          taskId: assignment.task_id,
          workerId: assignment.worker_id, // Ensure workerId is included
          shopId: assignment.shopName,
          assignedAt: assignment.assignedAt,
          status: assignment.status,
          verificationCode: assignment.verificationCode,
          verifiedAt: assignment.verifiedAt,
          taskDetails: task,
        };
      })
    );

    res.status(200).json(tasksWithDetails);
  } catch (err) {
    console.error('Error fetching assigned tasks:', err);
    res.status(500).json({ error: err.message });
  }
};