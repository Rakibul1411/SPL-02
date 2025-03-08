import Report from '../models/reportTable.js';
import Task from '../models/taskTable.js';
import TaskAssignment from '../models/taskAssignmentTable.js';

export const submitReport = async (req, res) => {
  try {
    const { taskId, reportText } = req.body; // Removed workerId from the request body

    console.log(req.body);

    if (!taskId || !reportText) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields (taskId, reportText)',
      });
    }

    // Step 1: Find the task assignment by taskId to get the workerId
    const taskAssignment = await TaskAssignment.findOne({ task_id: taskId });

    if (!taskAssignment) {
      return res.status(404).json({
        success: false,
        message: 'Task assignment not found for the given taskId',
      });
    }

    // Step 2: Get the workerId from the task assignment
    const workerId = taskAssignment.worker_id;

    if (!workerId) {
      return res.status(404).json({
        success: false,
        message: 'No worker found for the given task assignment',
      });
    }

    // Step 3: Check if the task is verified (verifiedAt is not null)
    if (!taskAssignment.verifiedAt) {
      return res.status(400).json({
        success: false,
        message: 'You are not verified by the shop. Please get verified before submitting the report.',
      });
    }

    // Extract uploaded file URLs
    const imageUrls = req.files['images']
      ? req.files['images'].map(file => `/uploads/${file.filename}`)
      : [];

    const fileUrls = req.files['files']
      ? req.files['files'].map(file => `/uploads/${file.filename}`)
      : [];

    // Step 4: Create and save the report
    const newReport = new Report({
      reportId: `${Date.now()}`,
      taskId,
      workerId, // Use the workerId fetched from the task assignment
      reportText,
      imageUrls,
      fileUrls,
    });

    await newReport.save();

    // Step 5: Update the status in TaskAssignmentTable to 'finished'
    taskAssignment.status = 'finished';
    await taskAssignment.save();

    // Step 6: Update the status in TaskTable to 'finished'
    const task = await Task.findById(taskId);
    if (task) {
      task.status = 'finished';
      await task.save();
    }

    res.status(201).json({
      success: true,
      message: 'Report submitted successfully',
      report: newReport,
    });
  } catch (error) {
    console.error('Error in submitReport:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to submit report',
      error: error.message || 'Unknown error',
    });
  }
};