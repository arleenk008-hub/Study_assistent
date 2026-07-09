const Note = require('../models/Note');

exports.uploadNote = async (req, res) => {
  try {
    const { title, description, fileUrl, price, category, examType } = req.body;
    const note = await Note.create({
      title,
      description,
      teacher: req.user._id,
      fileUrl,
      price,
      category,
      examType
    });
    res.status(201).json(note);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getNotes = async (req, res) => {
  try {
    const { category, examType, isFree } = req.query;
    let query = {};
    if (category) query.category = category;
    if (examType) query.examType = examType;
    if (isFree === 'true') query.price = 0;

    const notes = await Note.find(query).populate('teacher', 'name profilePicture');
    res.json(notes);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.rateNote = async (req, res) => {
  try {
    const { rating, review } = req.body;
    const note = await Note.findById(req.params.id);
    if (!note) return res.status(404).json({ message: 'Note not found' });

    note.ratings.push({ student: req.user._id, rating, review });
    
    const totalRating = note.ratings.reduce((acc, curr) => acc + curr.rating, 0);
    note.averageRating = totalRating / note.ratings.length;

    await note.save();
    res.json({ message: 'Rating added successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
