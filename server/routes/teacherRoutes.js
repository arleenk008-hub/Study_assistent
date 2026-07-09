const express = require('express');
const router = express.Router();
const { getTeachers, updateProfile, getTeacherById } = require('../controllers/teacherController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', getTeachers);
router.get('/:id', getTeacherById);
router.post('/profile', protect, updateProfile);

module.exports = router;
