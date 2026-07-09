const express = require('express');
const router = express.Router();
const PreviousYearPaper = require('../models/PreviousYearPaper');

router.get('/', async (req, res) => {
  try {
    const { examType, year } = req.query;
    let query = {};
    if (examType) query.examType = examType;
    if (year) query.year = year;

    const papers = await PreviousYearPaper.find(query);
    res.json(papers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
