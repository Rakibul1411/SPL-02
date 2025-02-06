import mongoose from 'mongoose';

const ReportSchema = new mongoose.Schema({
  reportId: { type: String, required: true, unique: true },
  taskId: { type: String, required: true },
  workerId: { type: String, required: true },
  reportText: { type: String, required: true },
  imageUrl: { type: String, required: false },
  submittedAt: { type: Date, default: Date.now },
  reportRating: { type: Number, default: null },
});

const Report = mongoose.model('Report', ReportSchema);

// Export the model
export default Report;




