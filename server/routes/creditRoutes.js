const express = require('express');
const router = express.Router();
const { awardAdCredits, deductAICredits, getWalletBalance } = require('../controllers/creditController');
const { protect } = require('../middleware/authMiddleware');

router.get('/balance', protect, getWalletBalance);
router.post('/reward-ad', protect, awardAdCredits);
router.post('/use-ai', protect, deductAICredits);

module.exports = router;
