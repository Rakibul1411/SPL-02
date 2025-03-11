import mongoose from "mongoose";

const incentiveAndRatingSchema = new mongoose.Schema({
  workerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    index: true
  },
  taskId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Task",
    required: true,
    index: true
  },

  // Incentive fields
  amount: {
    type: Number,
    default: 0
  },

  issuedAt: {
    type: Date,
    default: Date.now
  },

  // Rating fields
  rating: {
    type: Number,
    min: [1, 'Rating must be between 1 and 5'],
    max: 5,
    validate: {
      validator: function(v) {
        return v === undefined || v === null || (v >= 1 && v <= 5);
      },
      message: props => `${props.value} is not a valid rating! Must be between 1 and 5`
    }
  },

  feedback: {
    type: String,
    default: ""
  },

  ratedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    default: null,
    index: true
  },

  createdAt: {
    type: Date,
    default: Date.now
  },

  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: { createdAt: 'createdAt', updatedAt: 'updatedAt' }
});


incentiveAndRatingSchema.index({ workerId: 1, taskId: 1 }, { unique: true });

// Add virtual property to determine entry type
incentiveAndRatingSchema.virtual('type').get(function() {
  if (this.amount > 0 && this.rating > 0) return 'both';
  if (this.amount > 0) return 'incentive';
  if (this.rating > 0) return 'rating';
  return 'unknown';
});

// Add virtual for formatted date
incentiveAndRatingSchema.virtual('formattedDate').get(function() {
  return this.createdAt.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
});

// Pre-save hook to ensure updatedAt is set
incentiveAndRatingSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Create methods for instance operations
incentiveAndRatingSchema.methods.updateRating = async function(newRating, feedback, ratedBy) {
  if (newRating < 1 || newRating > 5) {
    throw new Error('Rating must be between 1 and 5');
  }

  this.rating = newRating;
  if (feedback) this.feedback = feedback;
  if (ratedBy) this.ratedBy = ratedBy;
  this.updatedAt = new Date();

  return this.save();
};

incentiveAndRatingSchema.methods.updateIncentive = async function(newAmount) {
  if (newAmount <= 0) {
    throw new Error('Incentive amount must be greater than 0');
  }

  this.amount = newAmount;
  this.updatedAt = new Date();

  return this.save();
};

// Create static methods for collection operations
incentiveAndRatingSchema.statics.findByWorker = function(workerId) {
  return this.find({ workerId });
};

incentiveAndRatingSchema.statics.findByTask = function(taskId) {
  return this.find({ taskId });
};

incentiveAndRatingSchema.statics.getAverageRatingForWorker = async function(workerId) {
  const result = await this.aggregate([
    { $match: { workerId: mongoose.Types.ObjectId(workerId), rating: { $gt: 0 } } },
    { $group: { _id: null, average: { $avg: "$rating" } } }
  ]);

  return result.length > 0 ? result[0].average : 0;
};

incentiveAndRatingSchema.statics.getTotalIncentivesForWorker = async function(workerId) {
  const result = await this.aggregate([
    { $match: { workerId: mongoose.Types.ObjectId(workerId), amount: { $gt: 0 } } },
    { $group: { _id: null, total: { $sum: "$amount" } } }
  ]);

  return result.length > 0 ? result[0].total : 0;
};

// Ensure virtuals are included in JSON
incentiveAndRatingSchema.set('toJSON', { virtuals: true });
incentiveAndRatingSchema.set('toObject', { virtuals: true });

// Export the merged schema as a model
export default mongoose.model("IncentiveAndRating", incentiveAndRatingSchema);