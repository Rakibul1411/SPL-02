import Report from '../models/reportTable.js';

export const submitReport = async (req, res) => {
  try {
    const { taskId, workerId, reportText, fileUrl } = req.body;

    if (!taskId || !workerId || !reportText) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields (taskId, workerId, reportText)',
      });
    }

    const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;

    const newReport = new Report({
      reportId: `${Date.now()}`,
      taskId,
      workerId,
      reportText,
      imageUrl,
      fileUrl, // Include fileUrl in the report
    });

    await newReport.save();

    res.status(201).json({
      success: true,
      message: 'Report submitted successfully',
      report: {
        reportId: newReport.reportId,
        taskId: newReport.taskId,
        workerId: newReport.workerId,
        reportText: newReport.reportText,
        imageUrl: newReport.imageUrl || '', // Ensure imageUrl is never null
        fileUrl: newReport.fileUrl || '', // Ensure fileUrl is never null
        submittedAt: newReport.submittedAt.toISOString(),
      },
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