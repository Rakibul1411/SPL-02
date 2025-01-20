import express from 'express';
import { getAllTasks, createTask, updateTask, deleteTask } from '../controller/taskController.js';

const router = express.Router();

router.get('/taskList', getAllTasks);

router.post('/taskCreate', createTask);

router.post('/taskUpdate/:id', updateTask);


router.post('/taskDelete/:id', deleteTask);

export default router;