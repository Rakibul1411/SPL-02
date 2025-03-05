import mongoose from "mongoose";

const incentiveAndRatingSchema = new mongoose.Schema({
  workerId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  taskId: { type: mongoose.Schema.Types.ObjectId, ref: "Task", required: true },

  // Incentive fields
  amount: { type: Number, default: 0 }, // Optional if not all documents have incentives
  issuedAt: { type: Date, default: Date.now }, // Optional

  // Rating fields
  rating: { type: Number, min: 1, max: 5, default: 0 }, // Optional if not all documents have ratings
  feedback: { type: String, default: "" }, // Optional
  ratedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null }, // Optional
  createdAt: { type: Date, default: Date.now }, // Optional
});

// Add indexes to improve query performance
incentiveAndRatingSchema.index({ workerId: 1, taskId: 1 });

// Add virtual property to determine entry type
incentiveAndRatingSchema.virtual('type').get(function() {
  if (this.amount > 0 && this.rating > 0) return 'both';
  if (this.amount > 0) return 'incentive';
  if (this.rating > 0) return 'rating';
  return 'unknown';
});

// Ensure virtuals are included in JSON
incentiveAndRatingSchema.set('toJSON', { virtuals: true });
incentiveAndRatingSchema.set('toObject', { virtuals: true });

// Export the merged schema as a model
export default mongoose.model("IncentiveAndRating", incentiveAndRatingSchema);