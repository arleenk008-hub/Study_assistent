import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/teacher_model.dart';
import '../../domain/repositories/teacher_repository_interface.dart';
import '../../data/repositories/mock_teacher_repository.dart';

final teacherRepositoryProvider = Provider<ITeacherRepository>((ref) {
  // Can be swapped with BackendTeacherRepository later
  return MockTeacherRepository();
});

final teachersListProvider = FutureProvider.family<List<TeacherProfile>, String?>((ref, subject) async {
  final repo = ref.watch(teacherRepositoryProvider);
  return repo.getTeachers(subject: subject);
});

final teacherDetailProvider = FutureProvider.family<TeacherProfile, String>((ref, id) async {
  final repo = ref.watch(teacherRepositoryProvider);
  return repo.getTeacherProfile(id);
});
