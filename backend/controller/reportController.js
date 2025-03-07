import Report from '../models/reportTable.js';

export const submitReport = async (req, res) => {
  try {
    const { taskId, workerId, reportText } = req.body;

    console.log(req.body);

    if (!taskId || !reportText) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields (taskId, workerId, reportText)',
      });
    }

    // Extract uploaded file URLs
    const imageUrls = req.files['images']
      ? req.files['images'].map(file => `/uploads/${file.filename}`)
      : [];

    const fileUrls = req.files['files']
      ? req.files['files'].map(file => `/uploads/${file.filename}`)
      : [];

    const newReport = new Report({
      reportId: `${Date.now()}`,
      taskId,
      workerId,
      reportText,
      imageUrls,
      fileUrls,
    });

    await newReport.save();

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
