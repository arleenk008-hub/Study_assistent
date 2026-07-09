import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/history_providers.dart';
import '../../domain/models/study_activity.dart';
import '../../../../core/theme/app_colors.dart';

class HistoryCalendarWidget extends ConsumerStatefulWidget {
  const HistoryCalendarWidget({super.key});

  @override
  ConsumerState<HistoryCalendarWidget> createState() => _HistoryCalendarWidgetState();
}

class _HistoryCalendarWidgetState extends ConsumerState<HistoryCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<StudyActivity> _getEventsForDay(DateTime day, List<StudyActivity> activities) {
    return activities.where((activity) => isSameDay(activity.startTime, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(paginatedHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return historyState.when(
      data: (activities) {
        return Column(
          children: [
            TableCalendar<StudyActivity>(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.now().add(const Duration(days: 1)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) => _getEventsForDay(day, activities),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                formatButtonTextStyle: const TextStyle(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildEventList(_getEventsForDay(_selectedDay ?? _focusedDay, activities), isDark),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEventList(List<StudyActivity> dayActivities, bool isDark) {
    if (dayActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            const Text('No activities for this day', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dayActivities.length,
      itemBuilder: (context, index) {
        final activity = dayActivities[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: isDark ? AppColors.surfaceDark : Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
          ),
          child: ListTile(
            leading: Icon(_getActivityIcon(activity.type), color: AppColors.primary, size: 20),
            title: Text(activity.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text(
              DateFormat('hh:mm a').format(activity.startTime),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: activity.duration != null 
              ? Text(_formatDuration(activity.duration!), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
              : null,
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.auth: return Icons.login;
      case ActivityType.studySession: return Icons.book;
      case ActivityType.liveClass: return Icons.videocam;
      case ActivityType.test: return Icons.assignment;
      case ActivityType.mockTest: return Icons.quiz;
      case ActivityType.assignment: return Icons.task;
      case ActivityType.note: return Icons.note;
      case ActivityType.video: return Icons.play_circle;
    }
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }
}
