import 'package:flutter/material.dart';

enum NotificationCategory { classUpdate, payment, notes, achievement, general }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final bool isImportant;
  final NotificationCategory category;
  final String? imageUrl;
  final IconData icon;
  final Color color;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.isImportant = false,
    required this.category,
    this.imageUrl,
    required this.icon,
    required this.color,
  });

  NotificationModel copyWith({bool? isRead, bool? isImportant}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isImportant: isImportant ?? this.isImportant,
      category: category,
      imageUrl: imageUrl,
      icon: icon,
      color: color,
    );
  }
}
