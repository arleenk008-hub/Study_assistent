class DailyStats {
  final DateTime date;
  final Duration totalStudyTime;
  final int classesCount;
  final int testsCount;
  final int mockTestsCount;
  final int assignmentsCount;
  final int videosCount;
  final int notesCount;

  DailyStats({
    required this.date,
    this.totalStudyTime = Duration.zero,
    this.classesCount = 0,
    this.testsCount = 0,
    this.mockTestsCount = 0,
    this.assignmentsCount = 0,
    this.videosCount = 0,
    this.notesCount = 0,
  });
}

class HistoryAnalytics {
  final List<DailyStats> dailyStats;
  final int currentStreak;
  final Duration averageStudyTime;
  final Duration longestSession;
  final String mostActiveDay;

  HistoryAnalytics({
    required this.dailyStats,
    this.currentStreak = 0,
    this.averageStudyTime = Duration.zero,
    this.longestSession = Duration.zero,
    this.mostActiveDay = '',
  });
}
