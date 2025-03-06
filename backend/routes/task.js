import express from 'express';
import { getAllTasksByCompanyId, createTask, updateTask, deleteTask, getTasksById, tasksAcceptedByWorkers, tasksRejectedByWorkers } from '../controller/taskController.js';

const router = express.Router();

// Get all tasks each individual company
router.get('/taskListByCompanyId/:email', getAllTasksByCompanyId);

// Get tasks by Id or email
router.get('/taskListById/:email', getTasksById);

// update tasks which is accepted by gig workers
router.post('/:id/taskAccepted/:email', tasksAcceptedByWorkers)

// update tasks which is rejected by gig workers
router.post('/:id/taskRejected/:email', tasksRejectedByWorkers)

// Create a new task
router.post('/taskCreate/', createTask);

// Update a task
router.post('/taskUpdate/:id', updateTask);

// Delete a task
router.delete('/taskDelete/:id', deleteTask);

export default router;