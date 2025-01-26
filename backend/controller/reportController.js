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