import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import '../providers/notifications_provider.dart';
import '../../domain/models/notification_model.dart';
import '../widgets/notification_shimmer.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _activeFilter = "All"; // All, Unread, Important, System, Study
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NotificationModel> _getFilteredNotifications(List<NotificationModel> all) {
    return all.where((n) {
      // Mapping categories for System/Study filters
      final isStudy = n.category == NotificationCategory.notes ||
          n.category == NotificationCategory.classUpdate ||
          n.category == NotificationCategory.achievement;
      final isSystem = n.category == NotificationCategory.payment ||
          n.category == NotificationCategory.general;

      bool matchesType = true;
      if (_activeFilter == "Unread") matchesType = !n.isRead;
      if (_activeFilter == "Important") matchesType = n.isImportant;
      if (_activeFilter == "Study") matchesType = isStudy;
      if (_activeFilter == "System") matchesType = isSystem;

      bool matchesSearch = n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.body.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allNotifications = ref.watch(notificationsProvider);
    final filtered = _getFilteredNotifications(allNotifications);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Mark all read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBarAndFilters(isDark),
          Expanded(
            child: _isLoading
                ? const NotificationShimmer()
                : RefreshIndicator(
                    onRefresh: _simulateLoading,
                    color: AppColors.primary,
                    child: filtered.isEmpty
                        ? _buildEmptyState(isDark)
                        : _buildGroupedList(filtered, isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarAndFilters(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search for alerts...',
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
              leading: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: ["All", "Unread", "Important", "Study", "System"].map((filter) {
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _activeFilter = filter),
                    backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.grey[700]),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<NotificationModel> notifications, bool isDark) {
    // Sorting by time
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final now = DateTime.now();
    final today = notifications.where((n) => _isSameDay(n.timestamp, now)).toList();
    final yesterday = notifications.where((n) => _isSameDay(n.timestamp, now.subtract(const Duration(days: 1)))).toList();
    final earlier = notifications.where((n) => n.timestamp.isBefore(DateTime(now.year, now.month, now.day - 1))).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (today.isNotEmpty) ...[_buildHeader("Today"), ...today.map((n) => _buildDismissible(n, isDark))],
        if (yesterday.isNotEmpty) ...[_buildHeader("Yesterday"), ...yesterday.map((n) => _buildDismissible(n, isDark))],
        if (earlier.isNotEmpty) ...[_buildHeader("Earlier"), ...earlier.map((n) => _buildDismissible(n, isDark))],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary, letterSpacing: 1.1)),
    );
  }

  Widget _buildDismissible(NotificationModel n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(n.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
        ),
        onDismissed: (_) => ref.read(notificationsProvider.notifier).deleteNotification(n.id),
        child: _NotificationCard(notification: n, isDark: isDark),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_rounded, size: 80, color: AppColors.primary.withOpacity(0.1)),
          const SizedBox(height: 24),
          const Text("All caught up!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("No notifications yet.", style: TextStyle(color: Colors.grey)),
        ],
      ).animate().fadeIn(),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

class _NotificationCard extends ConsumerWidget {
  final NotificationModel notification;
  final bool isDark;

  const _NotificationCard({required this.notification, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final isNew = DateTime.now().difference(n.timestamp).inMinutes < 60;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: n.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => ref.read(notificationsProvider.notifier).markAsRead(n.id),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(n, isDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppColors.textPrimary))),
                        Text(_formatTime(n.timestamp), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(n.body, style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (isNew && !n.isRead) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Text('NEW', style: TextStyle(color: AppColors.secondary, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
              _buildMenu(context, ref, n),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildAvatar(NotificationModel n, bool isDark) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: n.color.withOpacity(0.1),
          child: Icon(n.icon, color: n.color, size: 24),
        ),
        if (!n.isRead)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? AppColors.surfaceDark : Colors.white, width: 2),
            ),
          ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context, WidgetRef ref, NotificationModel n) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
      onSelected: (val) {
        if (val == 'read') ref.read(notificationsProvider.notifier).markAsRead(n.id);
        if (val == 'delete') ref.read(notificationsProvider.notifier).deleteNotification(n.id);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'details', child: Text('View Details')),
        if (!n.isRead) const PopupMenuItem(value: 'read', child: Text('Mark as Read')),
        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM dd').format(time);
  }
}
