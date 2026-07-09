import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/study_activity.dart';
import '../../../../core/theme/app_colors.dart';

class ActivityTimelineItem extends StatelessWidget {
  final StudyActivity activity;
  final bool isLast;

  const ActivityTimelineItem({
    super.key,
    required this.activity,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        children: [
          _buildTimelineIndicator(isDark),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _buildActivityCard(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator(bool isDark) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _getActivityColor(activity.type),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _getActivityColor(activity.type).withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              color: isDark ? Colors.white10 : Colors.grey[300],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getActivityColor(activity.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getActivityIcon(activity.type),
                      size: 14,
                      color: _getActivityColor(activity.type),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.type.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getActivityColor(activity.type),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('hh:mm a').format(activity.startTime),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activity.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (activity.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              activity.subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildActivityDetails(isDark),
        ],
      ),
    );
  }

  Widget _buildActivityDetails(bool isDark) {
    List<Widget> details = [];

    if (activity.duration != null) {
      details.add(_buildDetailChip(
        Icons.timer_outlined,
        _formatDuration(activity.duration!),
        isDark,
      ));
    }

    if (activity.status != null) {
      details.add(_buildDetailChip(
        Icons.info_outline,
        activity.status!,
        isDark,
        color: _getStatusColor(activity.status!),
      ));
    }

    if (activity.score != null) {
      details.add(_buildDetailChip(
        Icons.grade_outlined,
        'Score: ${activity.score}/${activity.totalMarks}',
        isDark,
        color: Colors.amber,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: details,
    );
  }

  Widget _buildDetailChip(IconData icon, String label, bool isDark, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? (isDark ? Colors.white38 : Colors.grey)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? (isDark ? Colors.white70 : Colors.black87),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.auth: return Colors.blue;
      case ActivityType.studySession: return AppColors.primary;
      case ActivityType.liveClass: return Colors.red;
      case ActivityType.test: return Colors.purple;
      case ActivityType.mockTest: return Colors.orange;
      case ActivityType.assignment: return Colors.teal;
      case ActivityType.note: return Colors.indigo;
      case ActivityType.video: return Colors.pink;
    }
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

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('pass') || s.contains('present') || s.contains('completed')) return Colors.green;
    if (s.contains('fail') || s.contains('absent')) return Colors.red;
    if (s.contains('late')) return Colors.orange;
    return Colors.grey;
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }
}
