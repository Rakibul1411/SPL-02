const express = require('express');
const { Task, Notification } = require('./models');
const router = express.Router();

// Create Task
router.post('/tasks', async (req, res) => {
  try {
    const task = new Task(req.body);
    await task.save();

    // Send Notification
    const notification = new Notification({
      userId: task.companyId,
      message: `New task created: ${task.title}`,
      type: 'TASK_CREATED',
    });
    await notification.save();

    res.status(201).json(task);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Assign Task
router.post('/tasks/assign', async (req, res) => {
  const { taskId, workerId } = req.body;
  try {
    const task = await Task.findById(taskId);
    if (!task) return res.status(404).json({ message: 'Task not found' });

    task.status = 'ASSIGNED';
    task.updatedAt = Date.now();
    await task.save();

    // Send Notification
    const notification = new Notification({
      userId: workerId,
      message: `You've been assigned a new task: ${task.title}`,
      type: 'TASK_ASSIGNED',
    });
    await notification.save();

    res.status(200).json({ message: 'Task assigned successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
