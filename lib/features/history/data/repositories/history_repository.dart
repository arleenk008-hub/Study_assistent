import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../../domain/models/study_activity.dart';
import '../../domain/repositories/history_repository_interface.dart';

class HistoryRepository implements IHistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _boxName = 'study_history_cache';

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<void> logActivity(StudyActivity activity) async {
    if (_uid == null) return;

    try {
      final docRef = _firestore.collection('users').doc(_uid).collection('history').doc();
      final activityWithId = StudyActivity(
        id: docRef.id,
        userId: _uid!,
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

      await docRef.set(activityWithId.toFirestore());
      
      // Cache locally
      final box = await Hive.openBox(_boxName);
      await box.put(activityWithId.id, activityWithId.toFirestore());
    } catch (e) {
      // Log to local storage for later sync if offline
      final box = await Hive.openBox('offline_history');
      await box.add(activity.toFirestore());
      rethrow;
    }
  }

  @override
  Stream<List<StudyActivity>> getActivities({
    DateTime? start,
    DateTime? end,
    ActivityType? type,
    int limit = 20,
  }) {
    if (_uid == null) return Stream.value([]);

    Query query = _firestore
        .collection('users')
        .doc(_uid)
        .collection('history')
        .orderBy('startTime', descending: true);

    if (start != null) {
      query = query.where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
    }
    if (end != null) {
      query = query.where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(end));
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StudyActivity.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<List<StudyActivity>> fetchPaginatedActivities({
    required int limit,
    StudyActivity? lastActivity,
  }) async {
    if (_uid == null) return [];

    Query query = _firestore
        .collection('users')
        .doc(_uid)
        .collection('history')
        .orderBy('startTime', descending: true)
        .limit(limit);

    if (lastActivity != null) {
      final lastDoc = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('history')
          .doc(lastActivity.id)
          .get();
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => StudyActivity.fromFirestore(doc)).toList();
  }

  @override
  Future<void> syncOfflineActivities() async {
    if (_uid == null) return;
    final box = await Hive.openBox('offline_history');
    if (box.isEmpty) return;

    for (var key in box.keys) {
      final data = Map<String, dynamic>.from(box.get(key));
      await _firestore.collection('users').doc(_uid).collection('history').add(data);
    }
    await box.clear();
  }
}
