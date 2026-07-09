import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../domain/models/notification_model.dart';

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super(_mockNotifications);

  void addNotification(NotificationModel notification) {
    state = [notification, ...state];
  }

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n
    ];
  }

  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  void deleteNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }

  void toggleImportant(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isImportant: !n.isImportant) else n
    ];
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  return NotificationsNotifier();
});

final unreadNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).toList();
});

final importantNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  return ref.watch(notificationsProvider).where((n) => n.isImportant).toList();
});

final _mockNotifications = [
  NotificationModel(
    id: '1',
    title: 'Live Class Starting Soon',
    body: 'Quantum Physics session by Dr. Satish begins in 10 minutes. Don\'t miss out!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    category: NotificationCategory.classUpdate,
    icon: Icons.videocam_rounded,
    color: Colors.blue,
    isRead: false,
    isImportant: true,
    imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&auto=format&fit=crop',
  ),
  NotificationModel(
    id: '2',
    title: 'Notes Uploaded',
    body: 'Handwritten notes for Organic Chemistry are now available in your notes section.',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    category: NotificationCategory.notes,
    icon: Icons.description_rounded,
    color: const Color(0xFF10B981),
    isRead: false,
  ),
  NotificationModel(
    id: '3',
    title: 'New Achievement!',
    body: 'Congratulations! You\'ve completed a 7-day study streak. Keep it up!',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    category: NotificationCategory.achievement,
    icon: Icons.emoji_events_rounded,
    color: Colors.orange,
    isRead: true,
    imageUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&auto=format&fit=crop',
  ),
  NotificationModel(
    id: '4',
    title: 'Payment Successful',
    body: 'Your subscription for Premium StudyAI has been processed successfully.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    category: NotificationCategory.payment,
    icon: Icons.account_balance_wallet_rounded,
    color: Colors.deepPurple,
    isRead: true,
  ),
];
