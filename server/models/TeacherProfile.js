const mongoose = require('mongoose');

const teacherProfileSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  qualification: { type: String, required: true },
  experience: { type: Number, default: 0 },
  subjects: [{ type: String }],
  competitiveExams: [{ type: String }],
  languages: [{ type: String }],
  bio: { type: String },
  fees: {
    oneToOne: { type: Number, default: 0 },
  },
  availability: [{
    day: { type: String },
    slots: [{ type: String }]
  }],
  rating: { type: Number, default: 0 },
  totalReviews: { type: Number, default: 0 },
  coverImage: { type: String, default: '' },
}, { timestamps: true });

module.exports = mongoose.model('TeacherProfile', teacherProfileSchema);
