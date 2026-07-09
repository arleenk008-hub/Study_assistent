import '../../domain/models/study_activity.dart';
import '../../domain/models/history_analytics.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  HistoryAnalytics calculateAnalytics(List<StudyActivity> activities) {
    if (activities.isEmpty) return HistoryAnalytics(dailyStats: []);

    final Map<DateTime, DailyStats> statsMap = {};
    Duration totalStudyTimeAcrossSessions = Duration.zero;
    Duration longestSession = Duration.zero;

    for (var activity in activities) {
      final date = DateTime(activity.startTime.year, activity.startTime.month, activity.startTime.day);
      
      final currentStats = statsMap[date] ?? DailyStats(date: date);
      
      Duration studyTime = Duration.zero;
      int classes = 0;
      int tests = 0;
      int mockTests = 0;
      int assignments = 0;
      int videos = 0;
      int notes = 0;

      switch (activity.type) {
        case ActivityType.studySession:
          studyTime = activity.duration ?? Duration.zero;
          if (studyTime > longestSession) longestSession = studyTime;
          totalStudyTimeAcrossSessions += studyTime;
          break;
        case ActivityType.liveClass:
          classes = 1;
          break;
        case ActivityType.test:
          tests = 1;
          break;
        case ActivityType.mockTest:
          mockTests = 1;
          break;
        case ActivityType.assignment:
          assignments = 1;
          break;
        case ActivityType.video:
          videos = 1;
          break;
        case ActivityType.note:
          notes = 1;
          break;
        default:
          break;
      }

      statsMap[date] = DailyStats(
        date: date,
        totalStudyTime: currentStats.totalStudyTime + studyTime,
        classesCount: currentStats.classesCount + classes,
        testsCount: currentStats.testsCount + tests,
        mockTestsCount: currentStats.mockTestsCount + mockTests,
        assignmentsCount: currentStats.assignmentsCount + assignments,
        videosCount: currentStats.videosCount + videos,
        notesCount: currentStats.notesCount + notes,
      );
    }

    final sortedStats = statsMap.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    
    int streak = _calculateStreak(sortedStats);
    
    final avgStudyTime = sortedStats.isEmpty 
        ? Duration.zero 
        : Duration(seconds: (totalStudyTimeAcrossSessions.inSeconds / sortedStats.length).round());

    String mostActiveDay = '';
    if (sortedStats.isNotEmpty) {
      final mostActive = sortedStats.reduce((a, b) => a.totalStudyTime > b.totalStudyTime ? a : b);
      mostActiveDay = DateFormat('EEEE').format(mostActive.date);
    }

    return HistoryAnalytics(
      dailyStats: sortedStats,
      currentStreak: streak,
      averageStudyTime: avgStudyTime,
      longestSession: longestSession,
      mostActiveDay: mostActiveDay,
    );
  }

  int _calculateStreak(List<DailyStats> stats) {
    if (stats.isEmpty) return 0;
    int streak = 0;
    DateTime today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (var stat in stats) {
      if (stat.date.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (stat.date.isBefore(checkDate)) {
        // Gap in streak
        break;
      }
    }
    return streak;
  }
}
