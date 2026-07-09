import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  auth,         // Login, Logout
  studySession, // Pomodoro, General Study
  liveClass,    // Joining/Leaving Live
  test,         // Subject Tests
  mockTest,     // Competitive Mocks
  assignment,   // Homework
  note,         // Reading/Creating Notes
  video         // Watching Lectures
}

class StudyActivity {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String? subtitle;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final Map<String, dynamic> metadata;
  final String? status; // Present, Completed, Pass, Fail
  
  // Scoring & Progress
  final double? score;
  final double? totalMarks;
  final int? attemptNumber;
  final String? teacherName;
  final double? completionPercentage;

  StudyActivity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.subtitle,
    required this.startTime,
    this.endTime,
    this.duration,
    this.metadata = const {},
    this.status,
    this.score,
    this.totalMarks,
    this.attemptNumber,
    this.teacherName,
    this.completionPercentage,
  });

  factory StudyActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyActivity(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: ActivityType.values.byName(data['type']),
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
      duration: data['durationSeconds'] != null ? Duration(seconds: data['durationSeconds']) : null,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      status: data['status'],
      score: (data['score'] as num?)?.toDouble(),
      totalMarks: (data['totalMarks'] as num?)?.toDouble(),
      attemptNumber: data['attemptNumber'],
      teacherName: data['teacherName'],
      completionPercentage: (data['completionPercentage'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationSeconds': duration?.inSeconds,
      'metadata': metadata,
      'status': status,
      'score': score,
      'totalMarks': totalMarks,
      'attemptNumber': attemptNumber,
      'teacherName': teacherName,
      'completionPercentage': completionPercentage,
    };
  }
}
