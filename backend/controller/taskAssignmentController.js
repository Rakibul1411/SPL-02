import Task from '../models/taskTable.js';
import User from "../models/userTable.js";
import TaskAssignment from '../models/taskAssignmentTable.js';
import { sendTaskEmailNotification } from "../utils/emailSender.js";

export const assignWorker = async (req, res) => {
  try {
    const { taskId, email } = req.params;

    const task = await Task.findById(taskId);

    task.isAssigned = true;
    await task.save();

    if (!task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    const worker = await User.findOne({ email: email });
    if (!worker) {
      return res.status(404).json({ error: 'Worker not found' });
    }

    const shopManager = await User.findOne({ name: task.shopName, role: "Shop Manager" });

    if (!shopManager) {
      return res.status(404).json({ error: 'Shop Manager not found for the given shop name' });
    }

    const newAssignment = new TaskAssignment({
      task_id: taskId,
      worker_id: worker._id,
      shop_id: shopManager._id,
      status: 'assigned',
      verificationCode: Math.random().toString(36).substring(2, 8),
    });

    await newAssignment.save();

    const shopManagerEmail = shopManager.email;

    const taskAssigned = await TaskAssignment.findOne({ task_id: taskId });
    if (!taskAssigned) {
      return res.status(404).json({ error: 'Task not found' });
    }

    await sendTaskEmailNotification([email, shopManagerEmail], task, taskAssigned);

    res.status(200).json({
      message: 'Worker assigned successfully',
      task,
      assignment: newAssignment,
      shopManagerEmail: shopManagerEmail
    });
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
          workerId: assignment.worker_id,
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

export const getShopTasks = async (req, res) => {
  try {
    const { shopId } = req.params;

    const shopIdString = shopId.toString();

    console.log('shop id:', shopIdString);

    const taskAssignments = await TaskAssignment.find({ shop_id: shopIdString });

    // Check if tasks are found
    if (!taskAssignments || taskAssignments.length === 0) {
      return res.status(200).json([]);  // Ensure it returns an empty array if no tasks are found
    }

    const tasksWithDetails = await Promise.all(
      taskAssignments.map(async (assignment) => {
        const task = await Task.findById(assignment.task_id);
        const worker = await User.findById(assignment.worker_id);

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
          taskDetails: task,
          workerDetails: workerDetails
        };
      })
    );

    // Send the correct response
    res.status(200).json(tasksWithDetails);
  } catch (err) {
    console.error('Error fetching shop tasks:', err);
    res.status(500).json({ error: err.message });
  }
};


export const verifyWorker = async (req, res) => {
  try {
    const { assignmentId, verificationCode } = req.body;

    const assignment = await TaskAssignment.findById(assignmentId);
    if (!assignment) {
      return res.status(404).json({ error: 'Task assignment not found' });
    }

    if (assignment.verificationCode !== verificationCode) {
      return res.status(400).json({ error: 'Invalid verification code' });
    }

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

    const shopManager = await User.findOne({ email: email });

    if (!shopManager) {
      return res.status(404).json({ error: 'Shop Manager not found with the given email' });
    }

    const shopIdString = shopManager._id.toString();

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