import '../models/study_activity.dart';

abstract class IHistoryRepository {
  Future<void> logActivity(StudyActivity activity);
  Stream<List<StudyActivity>> getActivities({
    DateTime? start,
    DateTime? end,
    ActivityType? type,
    int limit = 20,
  });
  Future<List<StudyActivity>> fetchPaginatedActivities({
    required int limit,
    StudyActivity? lastActivity,
  });
  Future<void> syncOfflineActivities();
}
