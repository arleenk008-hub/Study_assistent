import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import 'package:study_assistent/features/auth/presentation/providers/auth_provider.dart';
import 'package:study_assistent/features/history/presentation/providers/history_providers.dart';
import 'package:study_assistent/features/history/data/services/analytics_service.dart';
import 'package:study_assistent/features/history/presentation/widgets/study_timer_card.dart';
import 'package:study_assistent/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:study_assistent/features/notifications/presentation/widgets/notification_button.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  final ScrollController _categoryController = ScrollController();

  void _scrollCategories(bool forward) {
    final double offset = _categoryController.offset + (forward ? 200 : -200);
    _categoryController.animateTo(
      offset.clamp(0.0, _categoryController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final historyState = ref.watch(paginatedHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, user?.name ?? 'Student'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  
                  // Study Session Tracker
                  const StudyTimerCard(),
                  const SizedBox(height: 24),
                  
                  // Study Progress Section
                  _buildProgressSection(context, historyState, isDark),
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('Categories', onSeeAll: () => context.push('/search')),
                  const SizedBox(height: 16),
                  _buildCategoriesWithScroll(),
                  const SizedBox(height: 32),
                  _buildLiveClassesBanner(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Top Rated Teachers', onSeeAll: () => context.push('/search?filter=teachers')),
                  const SizedBox(height: 16),
                  _buildTeacherList(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Your Recent Lessons', onSeeAll: () => context.push('/videos')),
                  const SizedBox(height: 16),
                  _buildRecentLessons(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, AsyncValue<List> historyState, bool isDark) {
    return historyState.maybeWhen(
      data: (activities) {
        if (activities.isEmpty) return const SizedBox.shrink();
        final analytics = AnalyticsService().calculateAnalytics(activities.cast());
        return InkWell(
          onTap: () => context.push('/history'),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildProgressStat('Streak', '${analytics.currentStreak}d', Icons.local_fire_department, Colors.orange),
                const SizedBox(width: 24),
                _buildProgressStat('Avg. Time', _formatDuration(analytics.averageStudyTime), Icons.access_time, Colors.blue),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }

  Widget _buildAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $name 👋',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Ready to learn something new?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              const PremiumNotificationButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              'Search for teachers or courses...',
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildCategoriesWithScroll() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildCategories(),
        Positioned(
          left: 0,
          child: _scrollButton(false),
        ),
        Positioned(
          right: 0,
          child: _scrollButton(true),
        ),
      ],
    );
  }

  Widget _scrollButton(bool forward) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(forward ? Icons.arrow_forward_ios : Icons.arrow_back_ios, size: 16),
        onPressed: () => _scrollCategories(forward),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.school_rounded, 'label': 'Academics', 'color': Colors.blue},
      {'icon': Icons.code_rounded, 'label': 'Programming & Coding', 'color': Colors.green},
      {'icon': Icons.assignment_rounded, 'label': 'Competitive Exams', 'color': Colors.orange},
      {'icon': Icons.translate_rounded, 'label': 'Languages', 'color': Colors.purple},
      {'icon': Icons.palette_rounded, 'label': 'Design & Creativity', 'color': Colors.pink},
      {'icon': Icons.business_center_rounded, 'label': 'Business & Finance', 'color': Colors.teal},
      {'icon': Icons.music_note_rounded, 'label': 'Music', 'color': Colors.indigo},
      {'icon': Icons.fitness_center_rounded, 'label': 'Health & Fitness', 'color': Colors.red},
      {'icon': Icons.psychology_rounded, 'label': 'AI & Technology', 'color': Colors.cyan},
      {'icon': Icons.auto_stories_rounded, 'label': 'Personal Development', 'color': Colors.amber},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        controller: _categoryController,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['label'] as String,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveClassesBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Classes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Join interactive sessions with expert teachers in real-time.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Join Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherList(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => context.push('/teacher/T$index'),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=teacher'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dr. Sarah Wilson',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Mathematics',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star,
                        size: 14,
                        color: i < 4 ? Colors.amber : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentLessons(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => context.push('/videos'),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.play_circle_outline, color: AppColors.primary),
            ),
            title: Text(
              index == 0 ? 'Algebra - Quadratic Equations' : 'Quantum Physics Basics',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('24 mins remaining'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
