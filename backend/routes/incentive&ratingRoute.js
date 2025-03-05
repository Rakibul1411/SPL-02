// routes/incentiveRoutes.js
import express from "express";
import { issueIncentive, rateGigWorker, getWorkerRatings } from "../controllers/incentiveController.js";

const router = express.Router();

router.post("/issue", issueIncentive); // Issue incentive
router.post("/rate", rateGigWorker); // Rate gig worker
router.get("/worker/:workerId", getWorkerRatings); // Get worker's ratings

export default router;
