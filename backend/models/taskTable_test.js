import mongoose from "mongoose";

const TaskSchema = new mongoose.Schema({
  title: String,
  description: String,
  status: { type: String, default: "Pending" },
  assignedTo: String,
  verificationCode: String,
  deadline: Date,
});

//export default mongoose.model("Task", TaskSchema);

// ✅ Prevent Overwrite Error
export default mongoose.models.Task || mongoose.model("Task", TaskSchema);
