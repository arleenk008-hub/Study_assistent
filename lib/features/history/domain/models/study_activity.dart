import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  auth, studySession, liveClass, test, mockTest, assignment, note, video
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
  final String? status;
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
    return StudyActivity.fromMap(data, doc.id);
  }

  factory StudyActivity.fromMap(Map<String, dynamic> data, String id) {
    return StudyActivity(
      id: id,
      userId: data['userId'] ?? '',
      type: ActivityType.values.byName(data['type']),
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      startTime: _parseDate(data['startTime']),
      endTime: data['endTime'] != null ? _parseDate(data['endTime']) : null,
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

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
  }

  // Recursive safety for Hive
  static dynamic _makeHiveSafe(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is DateTime) {
      return value.toIso8601String();
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _makeHiveSafe(v)));
    } else if (value is List) {
      return value.map((e) => _makeHiveSafe(e)).toList();
    }
    return value;
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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': duration?.inSeconds,
      'metadata': _makeHiveSafe(metadata),
      'status': status,
      'score': score,
      'totalMarks': totalMarks,
      'attemptNumber': attemptNumber,
      'teacherName': teacherName,
      'completionPercentage': completionPercentage,
    };
  }
}
