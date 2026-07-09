import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type; // 'class', 'payment', 'ai', 'note'
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationNotifier() : super([
    NotificationItem(
      id: '1',
      title: 'Live Class Starting Soon',
      body: 'Quantum Physics class by Dr. Satish starts in 15 mins.',
      time: '10m ago',
      type: 'class',
    ),
    NotificationItem(
      id: '2',
      title: 'New Notes Uploaded',
      body: 'Organic Chemistry notes are now available for download.',
      time: '1h ago',
      type: 'note',
    ),
    NotificationItem(
      id: '3',
      title: 'Payment Successful',
      body: 'Your purchase of 50 credits was successful.',
      time: '2h ago',
      type: 'payment',
    ),
  ]);

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) NotificationItem(id: n.id, title: n.title, body: n.body, time: n.time, type: n.type, isRead: true)
        else n
    ];
  }

  void markAllAsRead() {
    state = [
      for (final n in state)
        NotificationItem(id: n.id, title: n.title, body: n.body, time: n.time, type: n.type, isRead: true)
    ];
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<NotificationItem>>((ref) {
  return NotificationNotifier();
});
