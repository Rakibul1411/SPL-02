import express from 'express';
import { getAllTasks, createTask, updateTask, deleteTask, getTasksById } from '../controller/taskController.js';

const router = express.Router();

// Get all tasks
router.get('/taskList', getAllTasks);

// Get tasks by Id or email
router.get('/taskListById', getTasksById);

// Create a new task
router.post('/taskCreate/', createTask);

// Update a task
router.post('/taskUpdate/:id', updateTask);

// Delete a task
router.delete('/taskDelete/:id', deleteTask);

export default router;