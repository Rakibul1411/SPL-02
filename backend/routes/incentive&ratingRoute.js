import express from "express";
import { issueIncentive, rateGigWorker, getWorkerRatings, getAllIncentivesAndRatings, addCombined } from "../controller/incentive&ratingController.js";

const router = express.Router();

router.post("/issue", issueIncentive); // Issue incentive
router.post("/rate", rateGigWorker); // Rate gig worker
router.get("/worker/:workerId", getWorkerRatings); // Get worker's ratings
router.get("/all", getAllIncentivesAndRatings);
// console.log("route");
router.post('/add-combined', addCombined);
// console.log("route2");
export default router;
