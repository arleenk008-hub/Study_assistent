const express = require('express');
const router = express.Router();
const { uploadNote, getNotes, rateNote } = require('../controllers/noteController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', getNotes);
router.post('/upload', protect, uploadNote);
router.post('/:id/rate', protect, rateNote);

module.exports = router;
