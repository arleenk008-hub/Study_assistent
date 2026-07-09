import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_chat_model.dart';

class ChatUINotifier extends StateNotifier<List<AIChatMessage>> {
  ChatUINotifier() : super([]);

  void sendMessage(String text) {
    final userMessage = AIChatMessage(
      id: DateTime.now().toIso8601String(),
      text: text,
      role: ChatRole.user,
      timestamp: DateTime.now(),
    );
    state = [...state, userMessage];

    // Simulate AI response
    _simulateResponse();
  }

  Future<void> _simulateResponse() async {
    await Future.delayed(const Duration(seconds: 2));
    final aiMessage = AIChatMessage(
      id: DateTime.now().toIso8601String(),
      text: "I can help you with that! Here's a structured explanation of the topic based on your request. Let me know if you need more details.",
      role: ChatRole.assistant,
      timestamp: DateTime.now(),
    );
    state = [...state, aiMessage];
  }

  void clearChat() {
    state = [];
  }

  void likeMessage(String id) {
    state = [
      for (final m in state)
        if (m.id == id) m.copyWith(isLiked: !m.isLiked, isDisliked: false) else m
    ];
  }

  void dislikeMessage(String id) {
    state = [
      for (final m in state)
        if (m.id == id) m.copyWith(isDisliked: !m.isDisliked, isLiked: false) else m
    ];
  }
}

final chatUIProvider = StateNotifierProvider<ChatUINotifier, List<AIChatMessage>>((ref) {
  return ChatUINotifier();
});

final isTypingProvider = StateProvider<bool>((ref) => false);
