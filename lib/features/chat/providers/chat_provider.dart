import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/chat_message.dart';
import '../data/services/ai_service.dart';

// In a real app, the API Key should be provided via --dart-define at build time
const _envApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

final aiServiceProvider = Provider((ref) => AIService(_envApiKey));

final chatTypingProvider = StateProvider<bool>((ref) => false);

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  ChatNotifier(this._ref) : super([]);

  void sendMessage(String text) async {
    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMessage];
    
    _ref.read(chatTypingProvider.notifier).state = true;
    
    try {
      final aiService = _ref.read(aiServiceProvider);
      final response = await aiService.sendMessage(text);
      
      final aiMessage = ChatMessage(
        text: response ?? "I'm sorry, I couldn't process that.",
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      );
      
      state = [...state, aiMessage];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(
          text: "An error occurred. Please check your connection.",
          role: MessageRole.ai,
          timestamp: DateTime.now(),
        )
      ];
    } finally {
      _ref.read(chatTypingProvider.notifier).state = false;
    }
  }

  void clearChat() {
    state = [];
    _ref.read(aiServiceProvider).resetChat();
  }
}
