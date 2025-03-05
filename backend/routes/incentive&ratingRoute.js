import express from "express";
import { issueIncentive, rateGigWorker, getWorkerRatings, getAllIncentivesAndRatings } from "../controller/incentive&ratingController.js";

const router = express.Router();

router.post("/issue", issueIncentive); // Issue incentive
router.post("/rate", rateGigWorker); // Rate gig worker
router.get("/worker/:workerId", getWorkerRatings); // Get worker's ratings
router.get("/all", getAllIncentivesAndRatings);
export default router;
