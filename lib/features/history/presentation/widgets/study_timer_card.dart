import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/history_service_provider.dart';

class StudyTimerCard extends ConsumerStatefulWidget {
  const StudyTimerCard({super.key});

  @override
  ConsumerState<StudyTimerCard> createState() => _StudyTimerCardState();
}

class _StudyTimerCardState extends ConsumerState<StudyTimerCard> {
  Timer? _timer;
  int _seconds = 0;
  bool _isActive = false;
  DateTime? _startTime;

  void _toggleTimer() async {
    if (_isActive) {
      // Stopping
      _timer?.cancel();
      final endTime = DateTime.now();
      await ref.read(historyServiceProvider).logStudySession(
        start: _startTime!,
        end: endTime,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Study session saved to history!')),
        );
      }
      setState(() {
        _isActive = false;
        _seconds = 0;
      });
    } else {
      // Starting
      _startTime = DateTime.now();
      setState(() => _isActive = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _seconds++);
      });
    }
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isActive ? AppColors.primary : (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isActive ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer_outlined,
              color: _isActive ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isActive ? 'Currently Studying' : 'Start Study Session',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isActive ? Colors.white : null,
                  ),
                ),
                Text(
                  _isActive ? _formatTime(_seconds) : 'Track your learning time',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isActive ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _toggleTimer,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isActive ? Colors.white : AppColors.primary,
              foregroundColor: _isActive ? AppColors.primary : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(0, 40),
            ),
            child: Text(_isActive ? 'Finish' : 'Start'),
          ),
        ],
      ),
    );
  }
}
