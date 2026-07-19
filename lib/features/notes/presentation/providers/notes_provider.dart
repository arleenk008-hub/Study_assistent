import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_assistent/features/notes/domain/models/note.dart';

// Mock notes for now
final teacherNotesProvider = StateNotifierProvider<TeacherNotesNotifier, List<Note>>((ref) {
  return TeacherNotesNotifier();
});

class TeacherNotesNotifier extends StateNotifier<List<Note>> {
  TeacherNotesNotifier() : super([]);

  void addNote(Note note) {
    state = [note, ...state];
  }

  void removeNote(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}
