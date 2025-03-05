// controllers/incentiveController.js
import Incentive from "../models/Incentive.js";
import Rating from "../models/Rating.js";

// Function to issue an incentive
export const issueIncentive = async (req, res) => {
  try {
    const { workerId, taskId, amount } = req.body;

    if (!workerId || !taskId || !amount) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const newIncentive = new Incentive({ workerId, taskId, amount });
    await newIncentive.save();

    res.status(201).json({ message: "Incentive issued successfully", incentive: newIncentive });
  } catch (error) {
    res.status(500).json({ error: "Failed to issue incentive", details: error.message });
  }
};

// Function to rate a gig worker
export const rateGigWorker = async (req, res) => {
  try {
    const { workerId, taskId, rating, feedback, ratedBy } = req.body;

    if (!workerId || !taskId || !rating || !ratedBy) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const newRating = new Rating({ workerId, taskId, rating, feedback, ratedBy });
    await newRating.save();

    res.status(201).json({ message: "Worker rated successfully", rating: newRating });
  } catch (error) {
    res.status(500).json({ error: "Failed to rate worker", details: error.message });
  }
};

// Function to get worker ratings
export const getWorkerRatings = async (req, res) => {
  try {
    const { workerId } = req.params;
    const ratings = await Rating.find({ workerId }).populate("taskId ratedBy", "title name");

    res.status(200).json(ratings);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch ratings", details: error.message });
  }
};
