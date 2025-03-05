// models/Incentive.js
import mongoose from "mongoose";

const incentiveSchema = new mongoose.Schema({
  workerId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  taskId: { type: mongoose.Schema.Types.ObjectId, ref: "Task", required: true },
  amount: { type: Number, required: true },
  issuedAt: { type: Date, default: Date.now },
});

export default mongoose.model("Incentive", incentiveSchema);

// models/Rating.js
import mongoose from "mongoose";

const ratingSchema = new mongoose.Schema({
  workerId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  taskId: { type: mongoose.Schema.Types.ObjectId, ref: "Task", required: true },
  rating: { type: Number, min: 1, max: 5, required: true },
  feedback: { type: String, required: false },
  ratedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  createdAt: { type: Date, default: Date.now },
});

export default mongoose.model("Rating", ratingSchema);
