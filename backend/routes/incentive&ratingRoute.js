import express from "express";
import { issueIncentive, rateGigWorker, getWorkerRatings, getAllIncentivesAndRatings, getLeaderboard } from "../controller/incentive&ratingController.js";

const router = express.Router();

router.post("/issue", issueIncentive); // Issue incentive
router.post("/rate", rateGigWorker); // Rate gig worker
router.get("/worker/:workerId", getWorkerRatings); // Get worker's ratings
router.get("/all", getAllIncentivesAndRatings);

// Add this new route for the leaderboard
router.get("/leaderboard/:email", getLeaderboard);

export default router;
