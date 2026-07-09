const mongoose = require('mongoose');

const creditTransactionSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true }, // positive for earned, negative for used
  type: { 
    type: String, 
    enum: ['ad_reward', 'ai_usage', 'teacher_session', 'purchase', 'daily_bonus'], 
    required: true 
  },
  description: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('CreditTransaction', creditTransactionSchema);
