import express from 'express';
import { getAllTasksByCompanyId, createTask, updateTask, deleteTask, getTasksById } from '../controller/taskController.js';

const router = express.Router();

// Get all tasks
router.get('/taskListByCompanyId/:email', getAllTasksByCompanyId);

// Get tasks by Id or email
router.get('/taskListById/:email', getTasksById);

// Create a new task
router.post('/taskCreate/', createTask);

// Update a task
router.post('/taskUpdate/:id', updateTask);

// Delete a task
router.delete('/taskDelete/:id', deleteTask);

export default router;