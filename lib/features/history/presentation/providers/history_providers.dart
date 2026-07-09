import 'package:flutter_riverpod/flutter_riverpod.dart';
// Using Package Imports instead of relative paths for better stability
import 'package:study_assistent/core/providers/auth_mode_provider.dart';
import 'package:study_assistent/features/history/domain/models/study_activity.dart';
import 'package:study_assistent/features/history/domain/repositories/history_repository_interface.dart';
import 'package:study_assistent/features/history/data/repositories/history_repository.dart';
import 'package:study_assistent/features/history/data/repositories/mock_history_repository.dart';
import 'history_filter_provider.dart';

final historyRepositoryProvider = Provider<IHistoryRepository>((ref) {
  final authMode = ref.watch(authModeProvider);
  
  // IF MOCK MODE -> Use Mock Repository (No Firebase Error)
  if (authMode == AuthMode.mock) {
    return MockHistoryRepository();
  }
  
  // IF SERVER MODE -> Use Firebase Repository
  return HistoryRepository();
});

final historyStreamProvider = StreamProvider.autoDispose<List<StudyActivity>>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  final filter = ref.watch(historyFilterProvider);
  
  return repository.getActivities(
    start: filter.startDate,
    end: filter.endDate,
    type: filter.type,
  );
});

final paginatedHistoryProvider = StateNotifierProvider<PaginatedHistoryNotifier, AsyncValue<List<StudyActivity>>>((ref) {
  return PaginatedHistoryNotifier(ref.watch(historyRepositoryProvider));
});

class PaginatedHistoryNotifier extends StateNotifier<AsyncValue<List<StudyActivity>>> {
  final IHistoryRepository _repository;
  final List<StudyActivity> _activities = [];
  bool _hasMore = true;
  StudyActivity? _lastActivity;

  PaginatedHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchMore();
  }

  Future<void> fetchMore() async {
    if (!_hasMore) return;

    try {
      final newActivities = await _repository.fetchPaginatedActivities(
        limit: 15,
        lastActivity: _lastActivity,
      );

      if (newActivities.isEmpty) {
        _hasMore = false;
      } else {
        _lastActivity = newActivities.last;
        _activities.addAll(newActivities);
      }
      state = AsyncValue.data(List.from(_activities));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    _activities.clear();
    _lastActivity = null;
    _hasMore = true;
    state = const AsyncValue.loading();
    await fetchMore();
  }
}
