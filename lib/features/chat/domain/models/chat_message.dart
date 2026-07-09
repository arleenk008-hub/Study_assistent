enum MessageRole { user, ai }

class ChatMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final List<String>? attachments;

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
    this.attachments,
  });
}
