import 'package:flutter/material.dart';

enum ChatRole { user, assistant }

class AIChatMessage {
  final String id;
  final String text;
  final ChatRole role;
  final DateTime timestamp;
  final bool isLiked;
  final bool isDisliked;

  AIChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.isLiked = false,
    this.isDisliked = false,
  });

  AIChatMessage copyWith({bool? isLiked, bool? isDisliked}) {
    return AIChatMessage(
      id: id,
      text: text,
      role: role,
      timestamp: timestamp,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
    );
  }
}
