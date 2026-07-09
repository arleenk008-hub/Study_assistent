import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_assistent/features/chat/domain/models/chat_message.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/backend_config.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

final chatTypingProvider = StateProvider<bool>((ref) => false);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  final ApiClient _apiClient = ApiClient();
  
  ChatNotifier(this._ref) : super([]);

  void sendMessage(String text) async {
    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    state = [...state, userMessage];

    await _getAIResponseFromBackend(text);
  }

  Future<void> _getAIResponseFromBackend(String prompt) async {
    _ref.read(chatTypingProvider.notifier).state = true;
    
    try {
      // Check if backend is configured
      if (!BackendConfig().isConfigured) {
        final errorMessage = ChatMessage(
          text: "Backend server is not configured. Please contact the administrator.",
          role: MessageRole.ai,
          timestamp: DateTime.now(),
        );
        state = [...state, errorMessage];
        return;
      }

      final aiChatEndpoint = ApiEndpoints.aiChat;
      if (aiChatEndpoint == null) {
        final errorMessage = ChatMessage(
          text: "Backend configuration error. Please contact the administrator.",
          role: MessageRole.ai,
          timestamp: DateTime.now(),
        );
        state = [...state, errorMessage];
        return;
      }

      // Get conversation history to send to backend for context
      final history = state.map((msg) => {
        'role': msg.role == MessageRole.user ? 'user' : 'model',
        'parts': [{'text': msg.text}]
      }).toList();

      final response = await _apiClient.post(
        aiChatEndpoint,
        {
          'prompt': prompt,
          'history': history.take(state.length - 1).toList(), // Exclude the latest message
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage = ChatMessage(
          text: data['text'],
          role: MessageRole.ai,
          timestamp: DateTime.now(),
        );
        state = [...state, aiMessage];
        
        // Deduct credits after successful AI usage
        final creditsEndpoint = ApiEndpoints.credits;
        if (creditsEndpoint != null) {
          try {
            await _apiClient.post('$creditsEndpoint/use-ai', {});
          } catch (_) {
            // Silently ignore credit deduction failures
          }
        }
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        text: "Sorry, I'm having trouble connecting to the server. Please check your credits or internet connection.",
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    } finally {
      _ref.read(chatTypingProvider.notifier).state = false;
    }
  }

  void clearHistory() {
    state = [];
  }
}
