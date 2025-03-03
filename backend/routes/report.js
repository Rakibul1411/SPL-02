import express from 'express';
import multer from 'multer';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { submitReport } from '../controller/reportController.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const router = express.Router();

// Ensure "uploads" directory exists
const uploadsDir = path.join(__dirname, '../uploads/');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Multer Storage Configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage, limits: { fileSize: 20 * 1024 * 1024 } });

// Route for submitting reports with multiple images and files
router.post('/submitReport', upload.fields([
  { name: 'images', maxCount: 20 },
  { name: 'files', maxCount: 20 },
]), async (req, res) => {
  try {
    console.log('Processing report submission...');
    await submitReport(req, res);
  } catch (error) {
    console.error('Error handling /submitReport:', error);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

export default router;
