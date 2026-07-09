const Payment = require('../models/Payment');
const User = require('../models/User');

// In a real app, you would use Razorpay/Stripe SDKs here
exports.createOrder = async (req, res) => {
  try {
    const { amount, purpose, metadata } = req.body;
    
    // Mocking Razorpay Order Creation
    const orderId = "order_" + Math.random().toString(36).slice(2);

    const payment = await Payment.create({
      user: req.user._id,
      amount,
      orderId,
      purpose,
      paymentGateway: 'razorpay',
      metadata
    });

    res.json({ orderId, amount, currency: 'INR' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.verifyPayment = async (req, res) => {
  try {
    const { orderId, paymentId, status } = req.body;
    const payment = await Payment.findOne({ orderId });

    if (!payment) return res.status(404).json({ message: 'Order not found' });

    payment.paymentId = paymentId;
    payment.status = status; // 'completed' or 'failed'
    await payment.save();

    if (status === 'completed') {
      // Logic for adding credits or unlocking notes
      if (payment.purpose === 'credits_purchase') {
        const user = await User.findById(payment.user);
        user.wallet.credits += (payment.amount / 10); // Example: 10 INR = 1 Credit
        await user.save();
      }
    }

    res.json({ message: 'Payment processed successfully', status });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
