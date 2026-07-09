const User = require('../models/User');
const CreditTransaction = require('../models/CreditTransaction');

// Award credits for watching ads
exports.awardAdCredits = async (req, res) => {
  try {
    const userId = req.user._id;
    const user = await User.findById(userId);

    // Logic: 10 ads = 20 credits. So 1 ad = 2 credits.
    // In production, you'd verify the ad completion via a callback or secure token.
    const creditsToAward = 2; 

    user.wallet.credits += creditsToAward;
    await user.save();

    await CreditTransaction.create({
      user: userId,
      amount: creditsToAward,
      type: 'ad_reward',
      description: 'Reward for watching an advertisement'
    });

    res.json({ 
      message: `Awarded ${creditsToAward} credits`, 
      totalCredits: user.wallet.credits 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Deduct credits for AI usage (30 mins = 2 credits)
// For simplicity, we can charge per interaction or session
exports.deductAICredits = async (req, res) => {
  try {
    const userId = req.user._id;
    const user = await User.findById(userId);

    const cost = 1; // Example: 1 credit per AI complex query

    if (user.wallet.credits < cost) {
      return res.status(403).json({ message: 'Insufficient credits' });
    }

    user.wallet.credits -= cost;
    await user.save();

    await CreditTransaction.create({
      user: userId,
      amount: -cost,
      type: 'ai_usage',
      description: 'Deduction for AI Assistant usage'
    });

    res.json({ 
      message: 'Credits deducted', 
      remainingCredits: user.wallet.credits 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getWalletBalance = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    res.json({ credits: user.wallet.credits });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
