import mongoose from 'mongoose';

const ReportSchema = new mongoose.Schema({
  reportId: {
    type: String,
    required: true,
    unique: true
  },
  taskId: {
    type: String,
    required: true
  },
  workerId: {
    type: String,
    required: false
  },
  reportText: {
    type: String,
    required: true
  },
  imageUrls: [{
    type: String,
    required: false
  }],
  fileUrls: [{
    type: String,
    required: false
  }],
  submittedAt: {
    type: Date,
    default: Date.now
  },
  reportRating: {
    type: Number,
    default: null
  },
});

const Report = mongoose.model('Report', ReportSchema);

export default Report;
