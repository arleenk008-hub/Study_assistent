import 'dart:async';
import '../../domain/models/study_activity.dart';
import '../../domain/repositories/history_repository_interface.dart';

class MockHistoryRepository implements IHistoryRepository {
  final List<StudyActivity> _mockActivities = [
    StudyActivity(
      id: '1',
      userId: 'mock_user',
      type: ActivityType.studySession,
      title: 'Mathematics Deep Dive',
      subtitle: 'Calculus and Integration',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().subtract(const Duration(hours: 1)),
      duration: const Duration(hours: 1),
      status: 'Completed',
    ),
    StudyActivity(
      id: '2',
      userId: 'mock_user',
      type: ActivityType.test,
      title: 'Physics Quiz',
      startTime: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      endTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      duration: const Duration(hours: 1),
      score: 85,
      totalMarks: 100,
      status: 'Pass',
    ),
    StudyActivity(
      id: '3',
      userId: 'mock_user',
      type: ActivityType.liveClass,
      title: 'Intro to Quantum Mechanics',
      subtitle: 'Teacher: Dr. Satish',
      startTime: DateTime.now().subtract(const Duration(days: 2)),
      endTime: DateTime.now().subtract(const Duration(days: 2, hours: -1)),
      duration: const Duration(hours: 1),
      status: 'Present',
    ),
  ];

  final _controller = StreamController<List<StudyActivity>>.broadcast();

  @override
  Future<void> logActivity(StudyActivity activity) async {
    final newActivity = StudyActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: activity.userId,
      type: activity.type,
      title: activity.title,
      subtitle: activity.subtitle,
      startTime: activity.startTime,
      endTime: activity.endTime,
      duration: activity.duration,
      metadata: activity.metadata,
      status: activity.status,
      score: activity.score,
      totalMarks: activity.totalMarks,
      attemptNumber: activity.attemptNumber,
      teacherName: activity.teacherName,
      completionPercentage: activity.completionPercentage,
    );
    _mockActivities.insert(0, newActivity);
    _controller.add(List.from(_mockActivities));
  }

  @override
  Stream<List<StudyActivity>> getActivities({
    DateTime? start,
    DateTime? end,
    ActivityType? type,
    int limit = 20,
  }) {
    // Return mock data filtered by type/date if needed
    _controller.add(List.from(_mockActivities));
    return _controller.stream;
  }

  @override
  Future<List<StudyActivity>> fetchPaginatedActivities({
    required int limit,
    StudyActivity? lastActivity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockActivities;
  }

  @override
  Future<void> syncOfflineActivities() async {
    // Do nothing in mock
  }
}
