import Task from '../models/taskTable.js';
import User from "../models/userTable.js";
import TaskAssignment from '../models/taskAssignmentTable.js'; // Corrected import statement
import { sendTaskEmailNotification } from "../utils/emailSender.js"; // Import email function

export const assignWorker = async (req, res) => {
  try {
    const { taskId, email } = req.params;

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

    // Fetch the shop manager's email based on the shop name from the task
    const shopManager = await User.findOne({ name: task.shopName, role: "Shop Manager" });

    if (!shopManager) {
      return res.status(404).json({ error: 'Shop Manager not found for the given shop name' });
    }

    // Create a new task assignment
    const newAssignment = new TaskAssignment({
      task_id: taskId,
      worker_id: worker._id, // Use the worker's ID
      shop_id: shopManager._id, // Assuming the task has a shopName field
      status: 'assigned',
      verificationCode: Math.random().toString(36).substring(2, 8), // Generate a random verification code
    });

    await newAssignment.save();

    const shopManagerEmail = shopManager.email;

    // Find the task assignment by task_id
    const taskAssigned = await TaskAssignment.findOne({ task_id: taskId });
    if (!taskAssigned) {
      return res.status(404).json({ error: 'Task not found' });
    }

    // Send email notification to the worker and the shop manager
    await sendTaskEmailNotification([email, shopManagerEmail], task, taskAssigned);

    res.status(200).json({
      message: 'Worker assigned successfully',
      task,
      assignment: newAssignment,
      shopManagerEmail: shopManagerEmail // Optionally return the shop manager's email
    });
  } catch (err) {
    console.error('Error assigning worker:', err);
    res.status(500).json({ error: err.message });
  }
};

export const fetchAssignedTasks = async (req, res) => {
  try {
    const { workerId } = req.params;
    console.log('hiiiii', workerId);

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

// New endpoint to fetch tasks for a shop manager
export const getShopTasks = async (req, res) => {
  try {
    const { shopId } = req.params;

    // Convert shop manager ID to string for comparison
    const shopIdString = shopId.toString();

    // Find all task assignments for this shop
    const taskAssignments = await TaskAssignment.find({ shop_id: shopIdString });

    if (!taskAssignments || taskAssignments.length === 0) {
      return res.status(200).json([]);
    }

    const tasksWithDetails = await Promise.all(
      taskAssignments.map(async (assignment) => {
        const task = await Task.findById(assignment.task_id);
        const worker = await User.findById(assignment.worker_id);

        // Include workerDetails but exclude sensitive information
        const workerDetails = worker ? {
          _id: worker._id,
          name: worker.name,
          email: worker.email,
          role: worker.role
        } : null;

        return {
          assignmentId: assignment._id,
          taskId: assignment.task_id,
          workerId: assignment.worker_id,
          shopId: assignment.shop_id,
          assignedAt: assignment.assignedAt,
          status: assignment.status,
          // Don't include verification code in the response for security
          verifiedAt: assignment.verifiedAt,
          taskDetails: task,
          workerDetails: workerDetails
        };
      })
    );

    res.status(200).json(tasksWithDetails);
  } catch (err) {
    console.error('Error fetching shop tasks:', err);
    res.status(500).json({ error: err.message });
  }
};

// New endpoint to verify a worker using the verification code
export const verifyWorker = async (req, res) => {
  try {
    const { assignmentId, verificationCode } = req.body;

    // Find the task assignment
    const assignment = await TaskAssignment.findById(assignmentId);
    if (!assignment) {
      return res.status(404).json({ error: 'Task assignment not found' });
    }

    // Verify the code
    if (assignment.verificationCode !== verificationCode) {
      return res.status(400).json({ error: 'Invalid verification code' });
    }

    // If already verified
    if (assignment.verifiedAt) {
      return res.status(400).json({ error: 'This task has already been verified' });
    }


    assignment.verifiedAt = new Date();
    await assignment.save();

    // Also update the task status if needed
//    const task = await Task.findById(assignment.task_id);
//    if (task) {
//      task.status = 'completed';
//      await task.save();
//    }

    res.status(200).json({
      message: 'Worker verified successfully',
      assignment
    });
  } catch (err) {
    console.error('Error verifying worker:', err);
    res.status(500).json({ error: err.message });
  }
};

export const getVerifiedShopTasks = async (req, res) => {
  try {
    const { email } = req.params;

    // Find the shop manager id based on email
    const shopManager = await User.findOne({ email: email });

    if (!shopManager) {
      return res.status(404).json({ error: 'Shop Manager not found with the given email' });
    }

    // Convert shop manager ID to string for comparison
    const shopIdString = shopManager._id.toString();

    // Find all task assignments for this shop with verifiedAt not null
    const taskAssignments = await TaskAssignment.find({
      shop_id: shopIdString,
      verifiedAt: { $ne: null }
    });

    if (!taskAssignments || taskAssignments.length === 0) {
      return res.status(200).json([]);
    }

    const tasksWithDetails = await Promise.all(
      taskAssignments.map(async (assignment) => {
        const task = await Task.findById(assignment.task_id);
        const worker = await User.findById(assignment.worker_id);

        // Include workerDetails but exclude sensitive information
        const workerDetails = worker ? {
          _id: worker._id,
          name: worker.name,
          email: worker.email,
          role: worker.role
        } : null;

        return {
          assignmentId: assignment._id,
          taskId: assignment.task_id,
          workerId: assignment.worker_id,
          shopId: assignment.shop_id,
          assignedAt: assignment.assignedAt,
          status: assignment.status,
          verifiedAt: assignment.verifiedAt,
          taskDetails: task ? {
            title: task.title,
            description: task.description,
            shopName: task.shopName,
            incentive: task.incentive,
            deadline: task.deadline,
            status: task.status,
          } : null,
          workerDetails: workerDetails
        };
      })
    );

    res.status(200).json(tasksWithDetails);
  } catch (err) {
    console.error('Error fetching verified shop tasks:', err);
    res.status(500).json({ error: err.message });
  }
};