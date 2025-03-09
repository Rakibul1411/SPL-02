import IncentiveAndRating from "../models/incentive&ratingTable.js";
import User from "../models/userTable.js";
import Task from "../models/taskTable.js";
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


// Get leaderboard data - top performers and requesting user
export const getLeaderboard = async (req, res) => {
  try {
    const { email } = req.params;

    // Debug info
    console.log(`Received leaderboard request for email: ${email}`);

    if (!email) {
      return res.status(400).json({ error: "Valid user email is required" });
    }

    // Find the user by email
    const user = await User.findOne({ email });

    if (!user) {
      console.log(`User not found with email: ${email}`);
      return res.status(404).json({ error: "User not found with the provided email" });
    }

    const userId = user._id;
    console.log(`Found user with ID: ${userId}`);

    // Step 1: Get all users with role "Gig Worker"
    const allUsers = await User.find({ role: "Gig Worker" }, '_id name email latitude longitude');
    console.log(`Found ${allUsers.length} gig workers`);

    // Step 2: Process all users to calculate their metrics
    const leaderboardData = await Promise.all(
      allUsers.map(async (user) => {
        try {
          // Get user's ratings (if any)
          const ratings = await IncentiveAndRating.find({
            workerId: user._id,
            rating: { $exists: true, $ne: null }
          });

          // Get user's incentives (if any)
          const incentives = await IncentiveAndRating.find({
            workerId: user._id,
            amount: { $exists: true, $gt: 0 }
          });

          // Calculate metrics
          const avgRating = ratings.length > 0
            ? ratings.reduce((sum, item) => sum + (item.rating || 0), 0) / ratings.length
            : 0; // Default to 0 if no ratings

          const totalAmount = incentives.length > 0
            ? incentives.reduce((sum, item) => sum + (item.amount || 0), 0)
            : 0;

          // Get the count of unique tasks (combining ratings and incentives)
          const taskIds = new Set([
            ...ratings.map(r => r.taskId?.toString() || ''),
            ...incentives.map(i => i.taskId?.toString() || '')
          ]);
          // Remove empty strings (null taskIds)
          taskIds.delete('');

          return {
            userId: user._id.toString(), // Convert ObjectId to string
            name: user.name || "Unknown",
            email: user.email || "",
            avgRating: parseFloat(avgRating.toFixed(1)),
            totalAmount: parseFloat(totalAmount.toFixed(2)),
            totalTasks: taskIds.size,
            latitude: user.latitude || 0,
            longitude: user.longitude || 0
          };
        } catch (err) {
          console.error(`Error processing user ${user._id}: ${err}`);
          // Return a default object with 0 values if there's an error
          return {
            userId: user._id.toString(),
            name: user.name || "Unknown",
            email: user.email || "",
            avgRating: 0,
            totalAmount: 0,
            totalTasks: 0,
            latitude: 0,
            longitude: 0
          };
        }
      })
    );

    // Ensure we have valid data
    console.log(`Processed ${leaderboardData.length} leaderboard entries`);

    // Step 3: Sort users by avgRating (descending) for ranking
    leaderboardData.sort((a, b) => b.avgRating - a.avgRating);

    // Step 4: Assign positions
    leaderboardData.forEach((user, index) => {
      user.position = index + 1;
    });

    // Step 5: Get top 5 users (or all if less than 5)
    const topCount = Math.min(5, leaderboardData.length);
    const topUsers = leaderboardData.slice(0, topCount);

    // Step 6: Check if the requesting user is in the data
    const requestingUserIndex = leaderboardData.findIndex(
      user => user.email === email
    );

    let response = {
      topUsers,
      userRank: requestingUserIndex >= 0 ? leaderboardData[requestingUserIndex].position : 0,
      currentUser: requestingUserIndex >= 0 ? leaderboardData[requestingUserIndex] : null,
    };

    // If user is not in top 5, include their data
    if (requestingUserIndex >= topCount) {
      response.currentUser = leaderboardData[requestingUserIndex];
    }

    console.log(`Sending response with ${topUsers.length} top users`);
    res.status(200).json(response);

  } catch (error) {
    console.error("Error generating leaderboard:", error);
    res.status(500).json({
      error: "Failed to generate leaderboard",
      details: error.message
    });
  }
};