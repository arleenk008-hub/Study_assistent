const Session = require('../models/Session');
// In a real app, you would use the 'agora-access-token' package
// const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

exports.generateToken = async (req, res) => {
  try {
    const { channelName, role } = req.body;
    
    // Mocking token generation for Agora
    const token = "mock_agora_token_" + Math.random().toString(36).slice(2);
    const appId = process.env.AGORA_APP_ID || "your_agora_app_id";

    res.json({ token, appId, channelName });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createSession = async (req, res) => {
  try {
    const { teacherId, startTime, type } = req.body;
    const session = await Session.create({
      student: req.user._id,
      teacher: teacherId,
      startTime,
      type,
      meetingId: "room_" + Math.random().toString(36).slice(2)
    });
    res.status(201).json(session);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
