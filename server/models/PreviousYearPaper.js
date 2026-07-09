const mongoose = require('mongoose');

const previousYearPaperSchema = new mongoose.Schema({
  title: { type: String, required: true },
  examType: { 
    type: String, 
    required: true,
    enum: ['JEE', 'NEET', 'UPSC', 'SSC', 'Banking', 'Railway', 'CUET', 'State Exams', 'Other']
  },
  year: { type: Number, required: true },
  fileUrl: { type: String, required: true },
  description: { type: String },
  subject: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('PreviousYearPaper', previousYearPaperSchema);
