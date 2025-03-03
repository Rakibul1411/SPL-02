import Task from "../models/taskTable_test.js";
import { io } from "../socket/socket.js";

// Assign a new task
export const assignTask = async (req, res) => {
  try {
    const { title, description, assignedTo, verificationCode, deadline } = req.body;

    const task = new Task({ title, description, assignedTo, verificationCode, deadline });
    await task.save();

    io.emit("newTask", task); // Send real-time notification

    res.status(201).json({ message: "Task assigned!", task });
  } catch (error) {
    res.status(500).json({ message: "Error assigning task", error });
  }
};

// Get tasks assigned to a user
export const getTasks = async (req, res) => {
  try {
    const tasks = await Task.find({ assignedTo: req.params.userId });
    res.status(200).json(tasks);
  } catch (error) {
    res.status(500).json({ message: "Error fetching tasks", error });
  }
};

// Verify a task
export const verifyTask = async (req, res) => {
  try {
    const { taskId, verificationCode } = req.body;
    const task = await Task.findById(taskId);

    if (!task) return res.status(404).json({ message: "Task not found" });

    if (task.verificationCode === verificationCode) {
      task.status = "Verified";
      await task.save();
      res.json({ message: "Task verified!", task });
    } else {
      res.status(400).json({ message: "Incorrect verification code" });
    }
  } catch (error) {
    res.status(500).json({ message: "Verification error", error });
  }
};
