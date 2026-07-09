import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/history_providers.dart';
import '../providers/history_filter_provider.dart';
import '../widgets/activity_timeline_item.dart';
import '../widgets/history_analytics_widget.dart';
import '../widgets/history_calendar_widget.dart';
import '../../domain/models/study_activity.dart';
import '../../data/services/export_service.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final ExportService _exportService = ExportService();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedHistoryProvider.notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyState = ref.watch(paginatedHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: const InputDecoration(
                hintText: 'Search activities...',
                border: InputBorder.none,
                filled: false,
              ),
              onChanged: (val) => ref.read(historyFilterProvider.notifier).setSearchQuery(val),
            )
          : const Text('Study History'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                ref.read(historyFilterProvider.notifier).setSearchQuery('');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _showExportOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Timeline', icon: Icon(Icons.timeline, size: 20)),
            Tab(text: 'Analytics', icon: Icon(Icons.insights, size: 20)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimelineView(historyState),
          const HistoryAnalyticsWidget(),
          const HistoryCalendarWidget(),
        ],
      ),
    );
  }

  Widget _buildTimelineView(AsyncValue<List<StudyActivity>> state) {
    return state.when(
      data: (activities) {
        final query = ref.watch(historyFilterProvider).searchQuery.toLowerCase();
        final filteredActivities = activities.where((a) => 
          a.title.toLowerCase().contains(query) || 
          (a.subtitle?.toLowerCase().contains(query) ?? false)
        ).toList();

        if (filteredActivities.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(paginatedHistoryProvider.notifier).refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: filteredActivities.length + 1,
            itemBuilder: (context, index) {
              if (index == filteredActivities.length) {
                return const SizedBox(height: 100); // Bottom padding
              }
              
              final activity = filteredActivities[index];
              bool showDateHeader = false;
              if (index == 0) {
                showDateHeader = true;
              } else {
                final prevActivity = filteredActivities[index - 1];
                if (!_isSameDay(activity.startTime, prevActivity.startTime)) {
                  showDateHeader = true;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDateHeader) _buildDateHeader(activity.startTime),
                  ActivityTimelineItem(
                    activity: activity,
                    isLast: index == filteredActivities.length - 1,
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String dateStr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDate = DateTime(date.year, date.month, date.day);

    if (activityDate == today) dateStr = 'Today';
    else if (activityDate == yesterday) dateStr = 'Yesterday';
    else dateStr = DateFormat('EEEE, MMM dd').format(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        dateStr,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white38 : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No activity records found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Start your first study session now!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FilterSheet(),
    );
  }

  void _showExportOptions(BuildContext context) {
    final activities = ref.read(paginatedHistoryProvider).value ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExportBottomSheet(activities: activities),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

class _ExportBottomSheet extends StatelessWidget {
  final List<StudyActivity> activities;
  const _ExportBottomSheet({required this.activities});

  @override
  Widget build(BuildContext context) {
    final exportService = ExportService();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Export Study Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.picture_as_pdf, color: Colors.white)),
              title: const Text('Save as PDF'),
              subtitle: const Text('Detailed report with graphs and stats'),
              onTap: () { Navigator.pop(context); exportService.exportToPdf(activities); },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.table_chart, color: Colors.white)),
              title: const Text('Save as Excel'),
              subtitle: const Text('Raw activity data for spreadsheets'),
              onTap: () { Navigator.pop(context); exportService.exportToExcel(activities); },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();
  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  DateTime? _start; DateTime? _end;

  @override
  void initState() {
    super.initState();
    final f = ref.read(historyFilterProvider);
    _start = f.startDate; _end = f.endDate;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(historyFilterProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter by Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2022), lastDate: DateTime.now());
                if (d != null) setState(() => _start = d);
              }, child: Text(_start == null ? 'Start Date' : DateFormat('MMM dd').format(_start!)))),
              const SizedBox(width: 16),
              Expanded(child: OutlinedButton(onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2022), lastDate: DateTime.now());
                if (d != null) setState(() => _end = d);
              }, child: Text(_end == null ? 'End Date' : DateFormat('MMM dd').format(_end!)))),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Activity Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            FilterChip(label: const Text('All'), selected: ref.watch(historyFilterProvider).type == null, onSelected: (_) => notifier.setType(null)),
            ...ActivityType.values.map((t) => FilterChip(label: Text(t.name.toUpperCase()), selected: ref.watch(historyFilterProvider).type == t, onSelected: (_) => notifier.setType(t))),
          ]),
          const SizedBox(height: 32),
          ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)), onPressed: () {
            if (_start != null && _end != null) notifier.setDateRange(_start!, _end!);
            ref.read(paginatedHistoryProvider.notifier).refresh();
            Navigator.pop(context);
          }, child: const Text('Apply Filters')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
