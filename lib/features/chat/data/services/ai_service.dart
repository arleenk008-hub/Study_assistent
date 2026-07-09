import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class AIService {
  final GenerativeModel _model;
  ChatSession? _chat;

  AIService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
          ),
        );

  Future<String?> sendMessage(String text, {List<File>? images}) async {
    try {
      _chat ??= _model.startChat();
      
      final content = images != null && images.isNotEmpty
          ? [
              Content.multi([
                TextPart(text),
                ...await Future.wait(images.map((f) async => 
                  DataPart('image/jpeg', await f.readAsBytes()))),
              ])
            ]
          : [Content.text(text)];

      final response = await _chat!.sendMessage(content.first);
      return response.text;
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  void resetChat() {
    _chat = null;
  }
}
