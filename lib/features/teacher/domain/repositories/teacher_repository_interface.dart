import '../models/teacher_model.dart';

abstract class ITeacherRepository {
  Future<List<TeacherProfile>> getTeachers({String? subject, double? maxPrice});
  Future<TeacherProfile> getTeacherProfile(String teacherId);
  Future<void> updateProfile(TeacherProfile profile);
  Future<void> setPricing(TeacherPricing pricing);
  Future<void> uploadNote(String title, String filePath);
  Future<void> startLiveClass(String classId);
  Future<void> bookSession(String teacherId, DateTime time);
}
