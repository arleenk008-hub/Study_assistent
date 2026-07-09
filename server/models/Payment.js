const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  currency: { type: String, default: 'INR' },
  status: { type: String, enum: ['pending', 'completed', 'failed'], default: 'pending' },
  paymentGateway: { type: String, enum: ['razorpay', 'stripe'], required: true },
  orderId: { type: String },
  paymentId: { type: String },
  purpose: { type: String, enum: ['credits_purchase', 'notes_purchase', 'course_purchase'], required: true },
  metadata: { type: Object }
}, { timestamps: true });

module.exports = mongoose.model('Payment', paymentSchema);
