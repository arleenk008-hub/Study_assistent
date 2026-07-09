const { GoogleGenerativeAI } = require('@google-generative-ai/generative-ai');

exports.getAIResponse = async (req, res) => {
  try {
    const { prompt, history } = req.body;
    
    if (!prompt) {
      return res.status(400).json({ message: 'Prompt is required' });
    }

    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

    // Format history for Gemini if provided
    const chat = model.startChat({
      history: history || [],
      generationConfig: {
        maxOutputTokens: 2048,
      },
    });

    const result = await chat.sendMessage(prompt);
    const response = await result.response;
    const text = response.text();

    res.json({ text });
  } catch (error) {
    console.error('AI Error:', error);
    res.status(500).json({ message: 'Error communicating with AI service' });
  }
};
