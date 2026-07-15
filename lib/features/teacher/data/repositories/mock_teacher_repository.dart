import '../../domain/models/teacher_model.dart';
import '../../domain/repositories/teacher_repository_interface.dart';

class MockTeacherRepository implements ITeacherRepository {
  final List<TeacherProfile> _mockTeachers = [
    TeacherProfile(
      id: 't1',
      userId: 'u1',
      name: 'Dr. Sarah Wilson',
      qualification: 'PhD in Mathematics',
      experience: 12,
      subjects: ['Calculus', 'Algebra', 'Statistics'],
      bio: 'Helping students master complex mathematical concepts for over a decade.',
      languages: ['English', 'Spanish'],
      availability: {'Mon': ['10:00 AM', '02:00 PM'], 'Wed': ['11:00 AM']},
      pricing: TeacherPricing(chat: 10, audioCall: 25, liveClass: 50, oneToOne: 120),
      averageRating: 4.9,
      totalReviews: 156,
      profilePicture: 'https://i.pravatar.cc/150?u=sarah',
    ),
    TeacherProfile(
      id: 't2',
      userId: 'u2',
      name: 'Prof. James Miller',
      qualification: 'MSc in Physics',
      experience: 8,
      subjects: ['Quantum Physics', 'Mechanics'],
      bio: 'Passionate about explaining the laws of the universe in simple terms.',
      languages: ['English', 'German'],
      availability: {'Tue': ['09:00 AM'], 'Thu': ['03:00 PM']},
      pricing: TeacherPricing(chat: 15, audioCall: 30, liveClass: 60, oneToOne: 150),
      averageRating: 4.7,
      totalReviews: 89,
      profilePicture: 'https://i.pravatar.cc/150?u=james',
    ),
  ];

  @override
  Future<List<TeacherProfile>> getTeachers({String? subject, double? maxPrice}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    var filtered = _mockTeachers;
    if (subject != null && subject.isNotEmpty) {
      filtered = filtered.where((t) => t.subjects.any((s) => s.toLowerCase().contains(subject.toLowerCase()))).toList();
    }
    return filtered;
  }

  @override
  Future<TeacherProfile> getTeacherProfile(String teacherId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockTeachers.firstWhere((t) => t.id == teacherId);
  }

  @override
  Future<void> updateProfile(TeacherProfile profile) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> setPricing(TeacherPricing pricing) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> uploadNote(String title, String filePath) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> startLiveClass(String classId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> bookSession(String teacherId, DateTime time) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
