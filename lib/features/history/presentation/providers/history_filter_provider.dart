import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/study_activity.dart';

class HistoryFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final ActivityType? type;
  final String searchQuery;

  HistoryFilter({
    this.startDate,
    this.endDate,
    this.type,
    this.searchQuery = '',
  });

  HistoryFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    ActivityType? type,
    String? searchQuery,
  }) {
    return HistoryFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HistoryFilterNotifier extends StateNotifier<HistoryFilter> {
  HistoryFilterNotifier() : super(HistoryFilter(
    startDate: DateTime.now().subtract(const Duration(days: 7)),
    endDate: DateTime.now(),
  ));

  void setDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void setType(ActivityType? type) {
    state = state.copyWith(type: type);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = HistoryFilter(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
  }
}

final historyFilterProvider = StateNotifierProvider<HistoryFilterNotifier, HistoryFilter>((ref) {
  return HistoryFilterNotifier();
});
