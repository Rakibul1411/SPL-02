import IncentiveAndRating from "../models/incentive&ratingTable.js";

// Issue an incentive
export const issueIncentive = async (req, res) => {
  try {
    const { workerId, taskId, amount } = req.body;
    if (!workerId || !taskId || !amount) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Check if an incentive already exists for this task and worker
    const existingIncentive = await IncentiveAndRating.findOne({
      workerId,
      taskId,
      amount: { $exists: true }
    });

    if (existingIncentive) {
      return res.status(400).json({
        error: "Incentive already exists for this worker and task"
      });
    }

    const newIncentive = new IncentiveAndRating({
      workerId,
      taskId,
      amount,
      issuedAt: new Date()
    });

    await newIncentive.save();
    res.status(201).json({
      message: "Incentive issued successfully",
      incentive: newIncentive
    });
  } catch (error) {
    res.status(500).json({
      error: "Failed to issue incentive",
      details: error.message
    });
  }
};

// Rate a gig worker
export const rateGigWorker = async (req, res) => {
  try {
    const { workerId, taskId, rating, feedback, ratedBy } = req.body;
    if (!workerId || !taskId || !rating) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Check if a rating already exists for this task and worker
    const existingRating = await IncentiveAndRating.findOne({
      workerId,
      taskId,
      rating: { $exists: true }
    });

    if (existingRating) {
      return res.status(400).json({
        error: "Rating already exists for this worker and task"
      });
    }

    const newRating = new IncentiveAndRating({
      workerId,
      taskId,
      rating,
      feedback: feedback || "",
      ratedBy,
      createdAt: new Date()
    });

    await newRating.save();
    res.status(201).json({
      message: "Worker rated successfully",
      rating: newRating
    });
  } catch (error) {
    res.status(500).json({
      error: "Failed to rate worker",
      details: error.message
    });
  }
};

// Get all ratings for a worker
export const getWorkerRatings = async (req, res) => {
  try {
    const { workerId } = req.params;
    if (!workerId) {
      return res.status(400).json({ error: "Worker ID is required" });
    }

    const ratings = await IncentiveAndRating.find({
      workerId,
      rating: { $exists: true, $ne: null }
    }).populate("taskId ratedBy", "title name");

    res.status(200).json(ratings);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch ratings",
      details: error.message
    });
  }
};

// ✅ 4. Fetch ALL Incentives & Ratings
export const getAllIncentivesAndRatings = async (req, res) => {
  try {
    const allData = await IncentiveAndRating.find()
      .populate("workerId", "name") // Populate worker name
      .populate("taskId", "title") // Populate task title
      .populate("ratedBy", "name"); // Populate rater's name


    // Ensure all fields exist to prevent frontend errors
    const sanitizedData = allData.map(item => {
      const doc = item.toObject();
      return {
        ...doc,
        rating: doc.rating || 0,
        feedback: doc.feedback || "",
        ratedBy: doc.ratedBy || null,
        amount: doc.amount || 0,
        issuedAt: doc.issuedAt || new Date(),
        createdAt: doc.createdAt || new Date(),
      };
    });

    res.status(200).json(sanitizedData);
  } catch (error) {
    console.error("Error in getAllIncentivesAndRatings:", error);
    res.status(500).json({
      error: "Failed to fetch incentives & ratings",
      details: error.message
    });
  }
};