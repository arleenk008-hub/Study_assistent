import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/study_activity.dart';
import '../../domain/repositories/history_repository_interface.dart';

class HistoryService {
  final IHistoryRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _loginTimestampKey = 'last_login_timestamp';

  HistoryService(this._repository);

  String? get _uid => _auth.currentUser?.uid;

  Future<void> logAuthActivity(bool isLogin) async {
    if (_uid == null) return;
    
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    
    if (isLogin) {
      await prefs.setString(_loginTimestampKey, now.toIso8601String());
      await _repository.logActivity(StudyActivity(
        id: '',
        userId: _uid!,
        type: ActivityType.auth,
        title: 'Login',
        startTime: now,
        status: 'Success',
      ));
    } else {
      final loginStr = prefs.getString(_loginTimestampKey);
      Duration? sessionDuration;
      if (loginStr != null) {
        final loginTime = DateTime.parse(loginStr);
        sessionDuration = now.difference(loginTime);
        await prefs.remove(_loginTimestampKey);
      }

      await _repository.logActivity(StudyActivity(
        id: '',
        userId: _uid!,
        type: ActivityType.auth,
        title: 'Logout',
        startTime: now,
        duration: sessionDuration,
        status: 'Success',
        metadata: {
          'sessionSeconds': sessionDuration?.inSeconds ?? 0,
        },
      ));
    }
  }

  Future<void> logStudySession({
    required DateTime start,
    required DateTime end,
    Duration? breakDuration,
  }) async {
    if (_uid == null) return;
    final duration = end.difference(start);
    await _repository.logActivity(StudyActivity(
      id: '',
      userId: _uid!,
      type: ActivityType.studySession,
      title: 'Study Session',
      startTime: start,
      endTime: end,
      duration: duration,
      metadata: {
        'breakDurationSeconds': breakDuration?.inSeconds ?? 0,
      },
    ));
  }

  Future<void> logLiveClass({
    required String className,
    required String teacherName,
    required DateTime start,
    required DateTime end,
    required String attendanceStatus,
  }) async {
    if (_uid == null) return;
    await _repository.logActivity(StudyActivity(
      id: '',
      userId: _uid!,
      type: ActivityType.liveClass,
      title: className,
      subtitle: 'Teacher: $teacherName',
      startTime: start,
      endTime: end,
      duration: end.difference(start),
      teacherName: teacherName,
      status: attendanceStatus,
    ));
  }

  Future<void> logTest({
    required String testName,
    required DateTime start,
    required DateTime submissionTime,
    required double score,
    required double totalMarks,
    bool isMock = false,
  }) async {
    if (_uid == null) return;
    final percentage = (score / totalMarks) * 100;
    await _repository.logActivity(StudyActivity(
      id: '',
      userId: _uid!,
      type: isMock ? ActivityType.mockTest : ActivityType.test,
      title: testName,
      startTime: start,
      endTime: submissionTime,
      duration: submissionTime.difference(start),
      score: score,
      totalMarks: totalMarks,
      status: percentage >= 40 ? 'Pass' : 'Fail',
      metadata: {
        'percentage': percentage,
      },
    ));
  }

  Future<void> logAssignmentActivity({
    required String assignmentTitle,
    required String status, // 'Started', 'Submitted'
    DateTime? startTime,
    DateTime? submissionTime,
  }) async {
    if (_uid == null) return;
    await _repository.logActivity(StudyActivity(
      id: '',
      userId: _uid!,
      type: ActivityType.assignment,
      title: assignmentTitle,
      startTime: startTime ?? DateTime.now(),
      endTime: submissionTime,
      duration: (startTime != null && submissionTime != null) 
          ? submissionTime.difference(startTime) 
          : null,
      status: status,
    ));
  }

  Future<void> logVideoActivity({
    required String videoTitle,
    required Duration watchDuration,
    required double completionPercentage,
    required bool isCompleted,
  }) async {
    if (_uid == null) return;
    await _repository.logActivity(StudyActivity(
      id: '',
      userId: _uid!,
      type: ActivityType.video,
      title: videoTitle,
      startTime: DateTime.now().subtract(watchDuration),
      endTime: DateTime.now(),
      duration: watchDuration,
      completionPercentage: completionPercentage,
      status: isCompleted ? 'Completed' : 'Incomplete',
    ));
  }

  Future<void> logNoteActivity({
    required String noteTitle,
    required String action, // 'Opened', 'Created', 'Edited'
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (_uid == null) return;
    final now = DateTime.now();
    await _repository.logActivity(StudyActivity(
      id: '',
      userId: _uid!,
      type: ActivityType.note,
      title: noteTitle,
      subtitle: 'Action: $action',
      startTime: startTime ?? now,
      endTime: endTime,
      duration: (startTime != null && endTime != null) ? endTime.difference(startTime) : null,
    ));
  }
}
