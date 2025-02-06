/*
import Report from '../models/reportTable.js';

// POST: Submit a new report
export const submitReport = async (req, res) => {
  const { taskId, workerId, reportText } = req.body;
  console.log("This is routeController.js");
  console.log(req.file);

  try {
    const newReport = new Report({
      reportId: `${Date.now()}`,
      taskId,
      workerId,
      reportText,
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null,
      submittedAt: new Date(),
    });

    await newReport.save();
    res.status(201).json({ message: 'Report submitted successfully', report: newReport });
  } catch (error) {
    res.status(500).json({ message: 'Failed to submit report', error: error.message });
  }

  console.log("This is end of routeController.js");
};


// GET: Retrieve all reports
export const getReports = async (req, res) => {
  try {
    const reports = await Report.find();
    res.status(200).json(reports);
  } catch (error) {
    console.error('Error fetching reports:', error);
    res.status(500).json({ message: 'Failed to retrieve reports', error: error.message });
  }
};
*/



import Report from '../models/reportTable.js';

export const submitReport = async (req, res) => {
  try {
    const { taskId, workerId, reportText } = req.body;
    const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;

    console.log('Received fields:', { taskId, workerId, reportText });
    console.log('Uploaded file:', req.file);

    const newReport = new Report({
      reportId: `${Date.now()}`,
      taskId,
      workerId,
      reportText,
      imageUrl,
    });

    await newReport.save();
    res.status(201).json({
      success: true,
      message: 'Report submitted successfully',
      report: newReport
    });
  } catch (error) {
    console.error('Error in submitReport:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to submit report',
      error: error.message
    });
  }
};