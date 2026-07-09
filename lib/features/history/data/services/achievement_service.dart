import 'package:hive/hive.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/study_activity.dart';
import '../../domain/models/history_analytics.dart';

class AchievementService {
  static const String _boxName = 'achievements';

  Future<List<Achievement>> getAchievements() async {
    final box = await Hive.openBox(_boxName);
    final List<Achievement> allAchievements = [
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Start a study session before 6 AM',
        icon: '🌅',
        target: 1,
      ),
      Achievement(
        id: 'study_marathon',
        title: 'Study Marathon',
        description: 'Complete a 4-hour study session',
        icon: '🏃',
        target: 1,
      ),
      Achievement(
        id: 'consistency_king',
        title: '7-Day Streak',
        description: 'Study for 7 consecutive days',
        icon: '👑',
        target: 7,
      ),
      Achievement(
        id: 'test_master',
        title: 'Test Master',
        description: 'Score 100% in 5 tests',
        icon: '💯',
        target: 5,
      ),
    ];

    List<Achievement> userAchievements = [];
    for (var a in allAchievements) {
      final data = box.get(a.id);
      if (data != null) {
        userAchievements.add(Achievement(
          id: a.id,
          title: a.title,
          description: a.description,
          icon: a.icon,
          target: a.target,
          isUnlocked: data['isUnlocked'] ?? false,
          progress: data['progress'] ?? 0.0,
          unlockedAt: data['unlockedAt'] != null ? DateTime.parse(data['unlockedAt']) : null,
        ));
      } else {
        userAchievements.add(a);
      }
    }
    return userAchievements;
  }

  Future<void> checkAchievements(List<StudyActivity> activities, HistoryAnalytics analytics) async {
    final box = await Hive.openBox(_boxName);
    
    // Check 7-Day Streak
    if (analytics.currentStreak >= 7) {
      await _unlockAchievement(box, 'consistency_king', 7.0 / 7.0);
    } else {
      await _updateProgress(box, 'consistency_king', analytics.currentStreak.toDouble() / 7.0);
    }

    // Check Study Marathon (4 hours = 14400 seconds)
    bool hasMarathon = activities.any((a) => a.type == ActivityType.studySession && (a.duration?.inSeconds ?? 0) >= 14400);
    if (hasMarathon) {
      await _unlockAchievement(box, 'study_marathon', 1.0);
    }

    // Check Early Bird
    bool hasEarlyBird = activities.any((a) => a.startTime.hour < 6);
    if (hasEarlyBird) {
      await _unlockAchievement(box, 'early_bird', 1.0);
    }

    // Check Test Master (100% scores)
    int perfectTests = activities.where((a) => a.type == ActivityType.test && a.score != null && a.score == a.totalMarks).length;
    await _updateProgress(box, 'test_master', perfectTests.toDouble() / 5.0);
    if (perfectTests >= 5) {
      await _unlockAchievement(box, 'test_master', 1.0);
    }
  }

  Future<void> _unlockAchievement(Box box, String id, double progress) async {
    final current = box.get(id);
    if (current != null && current['isUnlocked'] == true) return;

    await box.put(id, {
      'isUnlocked': true,
      'progress': 1.0,
      'unlockedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _updateProgress(Box box, String id, double progress) async {
    final current = box.get(id);
    if (current != null && current['isUnlocked'] == true) return;

    await box.put(id, {
      'isUnlocked': progress >= 1.0,
      'progress': progress > 1.0 ? 1.0 : progress,
      'unlockedAt': progress >= 1.0 ? DateTime.now().toIso8601String() : null,
    });
  }
}
