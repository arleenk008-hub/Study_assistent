import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/history_service.dart';
import 'history_providers.dart';

final historyServiceProvider = Provider<HistoryService>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryService(repository);
});
