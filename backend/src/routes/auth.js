import express from 'express';
import { registration,login } from '../../controller/auth.js';

const router = express.Router();

router.post('/registration', registration);
router.post('/login',login);

export default router;