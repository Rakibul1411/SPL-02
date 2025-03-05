import Task from '../models/taskTable.js';
import User from "../models/userTable.js";
import { sendTaskEmailNotification } from "../utils/emailSender.js"; // Import email function

// Fetch all tasks
export const getAllTasks = async (req, res) => {
  try {
    const tasks = await Task.find();
    //console.log('Fetched tasks:', tasks);
    res.status(200).json(tasks);
  } catch (err) {
    console.error('Error fetching tasks:', err);
    res.status(500).json({ error: err.message });
  }
};

// Create a new task
export const createTask = async (req, res) => {
  try {
    if (!req.body || Object.keys(req.body).length === 0) {
      return res.status(400).json({ error: "Empty request body" });
    }

    console.log("Request body:", req.body);
    // Validate and convert deadline
    const deadline = req.body.deadline ? new Date(req.body.deadline) : null;

    if (deadline && isNaN(deadline.getTime())) {
      return res.status(400).json({ error: "Invalid deadline format" });
    }

    // Create new task
    const newTask = new Task({ ...req.body, deadline });
    await newTask.save();

    // Fetch all gig workers from the database
    const gigWorkers = await User.find({ role: "Gig Worker" });

    if (gigWorkers.length > 0) {
      // Extract emails of all gig workers
      const gigWorkerEmails = gigWorkers.map((worker) => worker.email);

      console.log(gigWorkerEmails);

      // Send email to all gig workers
      await sendTaskEmailNotification(gigWorkerEmails, newTask);
    }

    // Send real-time notification to all gig workers
//    sendNotification({
//      title: "New Task Available",
//      message: `Task: ${newTask.title} is available!`,
//      taskId: newTask._id,
//    });

    res.status(201).json({ message: "Task created successfully", task: newTask });
  } catch (err) {
    console.error("Error creating task:", err);
    res.status(500).json({
      error: "Failed to create task",
      details: err.message,
    });
  }
};

// Update a task
export const updateTask = async (req, res) => {
  const { id } = req.params; // Extract the task ID from the URL
  const { title, description, location, incentive, deadline, status } = req.body;

  try {
    // Validate the deadline field
    if (deadline && isNaN(Date.parse(deadline))) {
      return res.status(400).json({ error: 'Invalid deadline format' });
    }

    const updatedTask = await Task.findByIdAndUpdate(
      id,
      { title, description, location, incentive, deadline, status },
      { new: true } // Return the updated task
    );

    if (!updatedTask) {
      return res.status(404).json({ message: 'Task not found' });
    }

    res.status(200).json({ message: 'Task updated successfully', task: updatedTask });
  } catch (error) {
    console.error('Error updating task:', error);
    res.status(500).json({ error: 'Failed to update task', details: error.message });
  }
};

// Delete a task
export const deleteTask = async (req, res) => {
  const { id } = req.params; // Extract the task ID from the URL

  console.log('your task id is:', id);

  try {
    const deletedTask = await Task.findByIdAndDelete(id);

    console.log(deletedTask);

    if (!deletedTask) {
      return res.status(404).json({ message: 'Task not found' });
    }

    res.status(200).json({ message: 'Task deleted successfully' });
  } catch (error) {
    console.error('Error deleting task:', error);
    res.status(500).json({ error: 'Failed to delete task', details: error.message });
  }
};