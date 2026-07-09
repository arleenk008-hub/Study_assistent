import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import 'package:study_assistent/features/auth/presentation/providers/auth_provider.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, user?.name ?? 'Instructor'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEarningsSummary(isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Live Classes', 'Schedule', () {}),
                  const SizedBox(height: 16),
                  _buildLiveClassesList(isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Student Requests', 'View All', () {}),
                  const SizedBox(height: 16),
                  _buildRequestsList(isDark),
                  const SizedBox(height: 32),
                  _buildQuickManagement(context, isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.secondary,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instructor Dashboard', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              IconButton(
                onPressed: () => context.push('/profile'),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('₹1,24,500.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryStat('14', 'Classes', Icons.video_camera_back),
              _summaryStat('89', 'Students', Icons.people_outline),
              _summaryStat('4.9', 'Rating', Icons.star_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String action, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }

  Widget _buildLiveClassesList(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.live_tv_rounded, color: Colors.red),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calculus - Level 2', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Starts in 45 mins', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(bool isDark) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Text('AD')),
        title: const Text('Aman Deep'),
        subtitle: const Text('Requested 1:1 Algebra Session'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.check_circle_outline, color: AppColors.secondary), onPressed: () {}),
            IconButton(icon: const Icon(Icons.cancel_outlined, color: AppColors.error), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickManagement(BuildContext context, bool isDark) {
    final tools = [
      {'icon': Icons.description_outlined, 'label': 'Upload Notes', 'color': Colors.blue},
      {'icon': Icons.quiz_outlined, 'label': 'Test Sheets', 'color': Colors.purple},
      {'icon': Icons.assignment_outlined, 'label': 'Assignments', 'color': Colors.orange},
      {'icon': Icons.chat_bubble_outline, 'label': 'Student Doubts', 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (tool['icon_color'] as Color? ?? tool['color'] as Color).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (tool['color'] as Color).withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(tool['icon'] as IconData, color: tool['color'] as Color),
              const SizedBox(width: 12),
              Text(tool['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        );
      },
    );
  }
}
