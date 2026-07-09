const TeacherProfile = require('../models/TeacherProfile');
const User = require('../models/User');

exports.getTeachers = async (req, res) => {
  try {
    const teachers = await TeacherProfile.find().populate('user', 'name profilePicture');
    res.json(teachers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const profile = await TeacherProfile.findOneAndUpdate(
      { user: req.user._id },
      { ...req.body },
      { new: true, upsert: true }
    );
    res.json(profile);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getTeacherById = async (req, res) => {
  try {
    const teacher = await TeacherProfile.findOne({ user: req.params.id }).populate('user', 'name profilePicture');
    if (!teacher) return res.status(404).json({ message: 'Teacher not found' });
    res.json(teacher);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
