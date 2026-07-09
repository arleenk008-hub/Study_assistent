import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());

class GeminiService {
  // Use environment variables for the API key in production
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
    );
    _chat = _model.startChat();
  }

  Future<String> getResponse(String prompt) async {
    if (_apiKey.isEmpty) {
      return "Please set your GEMINI_API_KEY in the environment variables.";
    }
    
    try {
      final response = await _chat.sendMessage(Content.text(prompt));
      return response.text ?? "I couldn't generate a response.";
    } catch (e) {
      return "Error: $e";
    }
  }
}
