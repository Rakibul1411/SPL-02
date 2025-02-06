/*
import multer from 'multer';
import express from 'express';
import fs from 'fs';
import path from 'path';
import { submitReport, getReports } from '../controller/reportController.js';


const router = express.Router();

console.log("This is route.js");



const uploadsDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir);
}

// Configure Multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

console.log("This is end 0f route.js");

router.post('/submitReport', upload.single('image'), submitReport);


export default router;
*/

////

import express from 'express';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import { submitReport } from '../controller/reportController.js';

// Get __dirname equivalent in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const router = express.Router();


// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, '../uploads/');
    fs.mkdirSync(dir, { recursive: true }); // Create directory if missing
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

// Route for submitting a report
router.post('/submitReport', upload.single('image'), submitReport);

export default router;





/*

// Configure Multer for file storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Save images in the "uploads" folder
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`); // Unique filename
  },
});

const upload = multer({ storage });

 POST: Image upload endpoint
router.post('/uploadImage', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No image provided' });
    }

    // Return the URL of the uploaded image
    const imageUrl = `/uploads/${req.file.filename}`;
    res.status(201).json({ imageUrl });
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({ message: 'Image upload failed', error: error.message });
  }
});

*/




/*
import express from 'express';
import { submitReport, getReports } from '../controller/reportController.js';


const router = express.Router();

router.post('/submitReport', submitReport);
//'http://10.0.2.2:3007/report/submitReport/';


export default router; */


/*
// POST: Submit a new report
router.post('/', submitReport);

// GET: Retrieve all reports
router.get('/', getReports);

module.exports = router;
*/


/*
import multer from 'multer';

// Configure Multer Storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Save images in "uploads" folder
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

// Initialize Multer
const upload = multer({ storage });

// POST: Submit a new report with image
router.post('/', upload.single('image'), async (req, res) => {
  const { reportId, taskId, workerId, reportText } = req.body;

  try {
    const newReport = new Report({
      reportId,
      taskId,
      workerId,
      reportText,
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null, // Save image URL
      submittedAt: new Date(),
    });

    await newReport.save();
    res.status(201).json({ message: 'Report submitted successfully', report: newReport });
  } catch (error) {
    console.error('Error submitting report:', error);
    res.status(500).json({ message: 'Failed to submit report', error: error.message });
  }
});

*/