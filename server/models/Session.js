const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema({
  student: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  teacher: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  startTime: { type: Date, required: true },
  endTime: { type: Date },
  status: { type: String, enum: ['scheduled', 'ongoing', 'completed', 'cancelled'], default: 'scheduled' },
  type: { type: String, enum: ['voice', 'video'], default: 'video' },
  creditsUsed: { type: Number, default: 0 },
  meetingId: { type: String }, // For Agora/WebRTC
}, { timestamps: true });

module.exports = mongoose.model('Session', sessionSchema);
