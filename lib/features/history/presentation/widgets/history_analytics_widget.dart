import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/history_providers.dart';
import '../../domain/models/history_analytics.dart';
import '../../data/services/analytics_service.dart';
import 'achievements_list.dart';

class HistoryAnalyticsWidget extends ConsumerWidget {
  const HistoryAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(paginatedHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return historyState.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('No data for analytics yet', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        
        final analytics = AnalyticsService().calculateAnalytics(activities);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakCard(analytics.currentStreak),
              const SizedBox(height: 24),
              
              // DAILY SUMMARY SECTION
              Text('Today\'s Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDailySummaryGrid(analytics.dailyStats.first),
              
              const SizedBox(height: 32),
              Text('Detailed Stats', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildStatsGrid(analytics, isDark),
              
              const SizedBox(height: 32),
              const Text('Learning Hours (7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildStudyGraph(analytics.dailyStats, isDark),
              
              const SizedBox(height: 32),
              const Text('Performance (Test Scores)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildPerformanceGraph(activities, isDark),
              
              const SizedBox(height: 32),
              const Text('Consistency Heatmap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildHeatmap(analytics.dailyStats, isDark),
              
              const SizedBox(height: 32),
              const AchievementsList(),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildDailySummaryGrid(DailyStats today) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(today.classesCount.toString(), 'Classes', Icons.videocam, Colors.red),
          _summaryItem(today.testsCount.toString(), 'Tests', Icons.assignment, Colors.purple),
          _summaryItem(today.notesCount.toString(), 'Notes', Icons.description, Colors.blue),
          _summaryItem(today.videosCount.toString(), 'Videos', Icons.play_circle, Colors.orange),
        ],
      ),
    );
  }

  Widget _summaryItem(String count, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9900), Color(0xFFFF4D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 50),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$streak Day Streak', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Keep learning to maintain your streak!', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(HistoryAnalytics analytics, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatBox('Avg. Session', _formatDuration(analytics.averageStudyTime), Icons.timer_outlined, Colors.blue),
        _buildStatBox('Longest Day', _formatDuration(analytics.longestSession), Icons.bolt_rounded, Colors.amber),
        _buildStatBox('Best Day', analytics.mostActiveDay, Icons.calendar_today_rounded, Colors.purple),
        _buildStatBox('Activity Rate', 'High', Icons.trending_up, Colors.green),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildStudyGraph(List<DailyStats> stats, bool isDark) {
    final last7Days = stats.take(7).toList().reversed.toList();
    if (last7Days.length < 2) return const Center(child: Text('Not enough data for study graph'));

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: _buildTitlesData(last7Days),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: last7Days.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalStudyTime.inMinutes.toDouble())).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceGraph(List activities, bool isDark) {
    final testActivities = activities.where((a) => a.score != null).toList().reversed.toList();
    if (testActivities.isEmpty) return const Center(child: Text('No test scores available'));

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: LineChart(
        LineChartData(
          minY: 0, maxY: 100,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: testActivities.asMap().entries.map((e) {
                final percentage = (e.value.score / e.value.totalMarks) * 100;
                return FlSpot(e.key.toDouble(), percentage);
              }).toList(),
              isCurved: false,
              color: AppColors.secondary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<DailyStats> days) {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            int idx = value.toInt();
            if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
            return Text(days[idx].date.day.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey));
          },
        ),
      ),
    );
  }

  Widget _buildHeatmap(List<DailyStats> stats, bool isDark) {
    final Map<DateTime, int> dataset = {};
    for (var stat in stats) dataset[stat.date] = stat.totalStudyTime.inMinutes;

    return HeatMap(
      datasets: dataset,
      colorMode: ColorMode.opacity,
      showText: false,
      scrollable: true,
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      endDate: DateTime.now(),
      colorsets: {
        1: const Color(0xFFE0E7FF),
        30: const Color(0xFFC7D2FE),
        60: const Color(0xFF818CF8),
        90: const Color(0xFF4F46E5),
        120: const Color(0xFF3730A3),
      },
      textColor: isDark ? Colors.white70 : Colors.black87,
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }
}
