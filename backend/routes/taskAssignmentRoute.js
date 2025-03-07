import express from 'express';
import { assignWorker, fetchAssignedTasks } from '../controller/taskAssignmentController.js';

const router = express.Router();

// Route for assigning a worker to a task
router.post('/assignWorker/:taskId/:email', assignWorker);

// Route for fetching assigned tasks for a worker
router.get('/getAssignedTasks/:workerId', fetchAssignedTasks);

export default router;