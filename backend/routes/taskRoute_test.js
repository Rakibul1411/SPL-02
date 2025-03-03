import express from "express";
import { assignTask, getTasks, verifyTask } from "../controller/taskController_test.js";

const router = express.Router();

router.post("/assign-task", assignTask);
router.get("/tasks/:userId", getTasks);
router.post("/verify-task", verifyTask);

export default router;
