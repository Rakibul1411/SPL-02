import Report from '../models/reportTable.js';
import Task from '../models/taskTable.js';
import User from '../models/userTable.js';
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

// New function to get reports by company ID
export const getReportsByCompany = async (req, res) => {

//  console.log("hiiiii");

  try {
    const { userEmail } = req.params;
    console.log(userEmail);
    if (!userEmail) {
      return res.status(400).json({
        success: false,
        message: 'Company Email is required',
      });
    }

    // Find the user (company) by email to get the companyId
    const user = await User.findOne({ email: userEmail });
    console.log(user);
    if (!user) {
       return res.status(404).json({ error: 'User not found' });
    }

    const companyId = user._id;
    console.log(companyId);
    // Step 1: Find all tasks created by the company
    const companyTasks = await Task.find({ companyId: companyId });
    console.log("company task print");
    console.log(companyTasks);
    if (!companyTasks || companyTasks.length === 0) {
      return res.status(200).json({
        success: true,
        message: 'No tasks found for this company',
        reports: [],
      });
    }

    // Step 2: Extract all task IDs
    const taskIds = companyTasks.map(task => task._id.toString());

    // Step 3: Find all reports associated with these task IDs
    let reports = await Report.find({ taskId: { $in: taskIds } }).sort({ submittedAt: -1 });
    console.log("report print");
    console.log(reports);
    // Step 4: Populate worker information and task information for each report
    const populatedReports = await Promise.all(reports.map(async (report) => {
      const reportObj = report.toObject();


      // Get worker information
      try {
        const worker = await User.findById(report.workerId);
        if (worker) {
          reportObj.workerName = `${worker.firstName} ${worker.lastName}`;
        }
      } catch (err) {
        console.error(`Error fetching worker info for report ${report.reportId}:`, err);
      }

      // Get task information
      try {
        const task = companyTasks.find(task => task._id.toString() === report.taskId);
        if (task) {
          reportObj.taskTitle = task.title || 'Untitled Task';
        }
      } catch (err) {
        console.error(`Error fetching task info for report ${report.reportId}:`, err);
      }

      return reportObj;
    }));

    console.log("populated report print");
    console.log(populatedReports);
    res.status(200).json({
      success: true,
      count: populatedReports.length,
      reports: populatedReports,
    });
  } catch (error) {
    console.error('Error in getReportsByCompany:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reports',
      error: error.message || 'Unknown error',
    });
  }
};