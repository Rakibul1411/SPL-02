import IncentiveAndRating from "../models/incentive&ratingTable.js";
import mongoose from "mongoose";

// Validate MongoDB ObjectId
const isValidObjectId = (id) => {
  return mongoose.Types.ObjectId.isValid(id);
};

// Issue an incentive
export const issueIncentive = async (req, res) => {
  try {
    const { workerId, taskId, amount } = req.body;

    // Enhanced validation
    if (!workerId || !taskId || !amount) {
      return res.status(400).json({ error: "All fields are required: workerId, taskId, and amount" });
    }

    if (!isValidObjectId(workerId) || !isValidObjectId(taskId)) {
      return res.status(400).json({ error: "Invalid workerId or taskId format" });
    }

    if (isNaN(amount) || amount <= 0) {
      return res.status(400).json({ error: "Amount must be a positive number" });
    }

    // Check if an incentive already exists for this task and worker
    const existingIncentive = await IncentiveAndRating.findOne({
      workerId,
      taskId,
      amount: { $exists: true }
    });

    if (existingIncentive) {
      return res.status(400).json({
        error: "Incentive already exists for this worker and task",
        existingIncentive
      });
    }

    // In issueIncentive function
    const newIncentive = new IncentiveAndRating({
      workerId,
      taskId,
      amount,
      issuedAt: new Date(),
      // Explicitly set rating to undefined to avoid validation
      rating: undefined
    });

    await newIncentive.save();
    res.status(201).json({
      message: "Incentive issued successfully",
      incentive: newIncentive
    });
  } catch (error) {
    console.error("Error issuing incentive:", error);
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

    // Enhanced validation
    if (!workerId || !taskId || !rating) {
      return res.status(400).json({ error: "Required fields missing: workerId, taskId, and rating" });
    }

    if (!isValidObjectId(workerId) || !isValidObjectId(taskId)) {
      return res.status(400).json({ error: "Invalid workerId or taskId format" });
    }

    if (!ratedBy || !isValidObjectId(ratedBy)) {
      return res.status(400).json({ error: "Valid ratedBy user ID is required" });
    }

    const ratingNum = Number(rating);
    if (isNaN(ratingNum) || ratingNum < 1 || ratingNum > 5) {
      return res.status(400).json({ error: "Rating must be a number between 1 and 5" });
    }

    // Check if a rating already exists for this task and worker
    const existingRating = await IncentiveAndRating.findOne({
      workerId,
      taskId,
      rating: { $exists: true, $ne: null }
    });

    if (existingRating) {
      return res.status(400).json({
        error: "Rating already exists for this worker and task",
        existingRating
      });
    }

    const newRating = new IncentiveAndRating({
      workerId,
      taskId,
      rating: ratingNum,
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
    console.error("Error rating worker:", error);
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

    if (!isValidObjectId(workerId)) {
      return res.status(400).json({ error: "Invalid worker ID format" });
    }

    const ratings = await IncentiveAndRating.find({
      workerId,
      rating: { $exists: true, $ne: null }
    }).populate("taskId", "title")
      .populate("ratedBy", "name");

    // Calculate average rating
    const avgRating = ratings.length > 0
      ? ratings.reduce((sum, item) => sum + item.rating, 0) / ratings.length
      : 0;

    res.status(200).json({
      ratings,
      count: ratings.length,
      averageRating: parseFloat(avgRating.toFixed(1))
    });
  } catch (error) {
    console.error("Error fetching worker ratings:", error);
    res.status(500).json({
      error: "Failed to fetch ratings",
      details: error.message
    });
  }
};

// ✅ 4. Fetch ALL Incentives & Ratings
export const getAllIncentivesAndRatings = async (req, res) => {
  try {
    // Add pagination support
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Add filtering support
    const filter = {};
    if (req.query.workerId && isValidObjectId(req.query.workerId)) {
      filter.workerId = req.query.workerId;
    }
    if (req.query.taskId && isValidObjectId(req.query.taskId)) {
      filter.taskId = req.query.taskId;
    }
    if (req.query.type === 'rating') {
      filter.rating = { $exists: true, $ne: null };
    } else if (req.query.type === 'incentive') {
      filter.amount = { $exists: true, $gt: 0 };
    }

    // Get total count for pagination
    const total = await IncentiveAndRating.countDocuments(filter);

    // Get data with pagination
    const allData = await IncentiveAndRating.find(filter)
      .populate("workerId", "name email") // Include email in population
      .populate("taskId", "title description") // Include description in population
      .populate("ratedBy", "name")
      .sort({ createdAt: -1 }) // Sort by newest first
      .skip(skip)
      .limit(limit);

    // Ensure all fields exist to prevent frontend errors
    const sanitizedData = allData.map(item => {
      const doc = item.toObject();
      return {
        ...doc,
        rating: doc.rating || 0,
        feedback: doc.feedback || "",
        ratedBy: doc.ratedBy || null,
        amount: doc.amount || 0,
        issuedAt: doc.issuedAt || doc.createdAt || new Date(),
        createdAt: doc.createdAt || new Date(),
      };
    });

    res.status(200).json({
      data: sanitizedData,
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error("Error in getAllIncentivesAndRatings:", error);
    res.status(500).json({
      error: "Failed to fetch incentives & ratings",
      details: error.message
    });
  }
};

// New endpoint: Get analytics for incentives and ratings
export const getAnalytics = async (req, res) => {
  try {
    // Get total counts
    const [totalRatings, totalIncentives] = await Promise.all([
      IncentiveAndRating.countDocuments({ rating: { $exists: true, $ne: null } }),
      IncentiveAndRating.countDocuments({ amount: { $exists: true, $gt: 0 } })
    ]);

    // Get average rating
    const ratingResult = await IncentiveAndRating.aggregate([
      { $match: { rating: { $exists: true, $ne: null } } },
      { $group: { _id: null, average: { $avg: "$rating" } } }
    ]);
    const averageRating = ratingResult.length > 0 ?
      parseFloat(ratingResult[0].average.toFixed(1)) : 0;

    // Get total and average incentive amount
    const incentiveResult = await IncentiveAndRating.aggregate([
      { $match: { amount: { $exists: true, $gt: 0 } } },
      { $group: {
        _id: null,
        total: { $sum: "$amount" },
        average: { $avg: "$amount" }
      } }
    ]);
    const totalAmount = incentiveResult.length > 0 ?
      parseFloat(incentiveResult[0].total.toFixed(2)) : 0;
    const averageAmount = incentiveResult.length > 0 ?
      parseFloat(incentiveResult[0].average.toFixed(2)) : 0;

    res.status(200).json({
      counts: {
        totalRatings,
        totalIncentives,
      },
      ratings: {
        average: averageRating
      },
      incentives: {
        totalAmount,
        averageAmount
      }
    });
  } catch (error) {
    console.error("Error getting analytics:", error);
    res.status(500).json({
      error: "Failed to get analytics",
      details: error.message
    });
  }
};

// Add combined rating and incentive
export const addCombined = async (req, res) => {
    console.log("controller");
  try {
    const { workerId, taskId, rating, feedback, ratedBy, amount } = req.body;

    // Validation
    if (!workerId || !taskId) {
      return res.status(400).json({ error: "WorkerId and taskId are required" });
    }

    if (!isValidObjectId(workerId) || !isValidObjectId(taskId)) {
      return res.status(400).json({ error: "Invalid workerId or taskId format" });
    }

    // Check if at least one of rating or amount is provided
    if ((rating === undefined || rating === null) && (amount === undefined || amount === null)) {
      return res.status(400).json({ error: "At least one of rating or amount must be provided" });
    }

    // Validate rating if provided
    if (rating !== undefined && rating !== null) {
      const ratingNum = Number(rating);
      if (isNaN(ratingNum) || ratingNum < 1 || ratingNum > 5) {
        return res.status(400).json({ error: "Rating must be a number between 1 and 5" });
      }

      if (!ratedBy || !isValidObjectId(ratedBy)) {
        return res.status(400).json({ error: "Valid ratedBy user ID is required for ratings" });
      }
    }

    // Validate amount if provided
    if (amount !== undefined && amount !== null) {
      if (isNaN(amount) || amount <= 0) {
        return res.status(400).json({ error: "Amount must be a positive number" });
      }
    }

    // Find existing entry or create new one using findOneAndUpdate with upsert
    const update = {};

    // Set rating fields if provided
    if (rating !== undefined && rating !== null) {
      update.rating = Number(rating);
      update.feedback = feedback || "";
      update.ratedBy = ratedBy;
    }

    // Set amount if provided
    if (amount !== undefined && amount !== null) {
      update.amount = Number(amount);
      update.issuedAt = new Date();
    }

    // Add timestamps
    update.updatedAt = new Date();
    if (!update.createdAt) {
      update.createdAt = new Date();
    }

    const options = {
      upsert: true,
      new: true,
      setDefaultsOnInsert: true
    };

    const result = await IncentiveAndRating.findOneAndUpdate(
      { workerId, taskId },
      update,
      options
    );

    res.status(201).json({
      message: "Data saved successfully",
      data: result
    });
  } catch (error) {
    console.error("Error saving combined data:", error);
    res.status(500).json({
      error: "Failed to save data",
      details: error.message
    });
  }
};