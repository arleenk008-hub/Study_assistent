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
          _buildAppBar(context, user?.name ?? 'Instructor', user?.profilePicture),
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
                  _buildSectionHeader(
                    'Student Requests', 
                    'View All', 
                    () => context.push('/student-requests'),
                  ),
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

  Widget _buildAppBar(BuildContext context, String name, String? profilePic) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.secondary,
                  backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
                  child: profilePic == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructor Dashboard',
                        style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const Icon(Icons.notifications_none_rounded),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_outlined),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
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
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('₹1,24,500.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _summaryStat('14', 'Classes', Icons.video_camera_back)),
              Flexible(child: _summaryStat('89', 'Students', Icons.people_outline)),
              Flexible(child: _summaryStat('4.9', 'Rating', Icons.star_outline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String value, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white60, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String action, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          child: Text(action),
        ),
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
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calculus - Level 2', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text('Starts in 45 mins', style: TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
        title: const Text('Aman Deep', overflow: TextOverflow.ellipsis),
        subtitle: const Text('Requested 1:1 Algebra Session', overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: AppColors.secondary),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickManagement(BuildContext context, bool isDark) {
    final tools = [
      {
        'icon': Icons.description_outlined, 
        'label': 'Upload Notes', 
        'color': Colors.blue,
        'route': '/add-note'
      },
      {
        'icon': Icons.quiz_outlined, 
        'label': 'Test Sheets', 
        'color': Colors.purple,
        'route': null
      },
      {
        'icon': Icons.assignment_outlined, 
        'label': 'Assignments', 
        'color': Colors.orange,
        'route': null
      },
      {
        'icon': Icons.chat_bubble_outline, 
        'label': 'Student Doubts', 
        'color': Colors.teal,
        'route': '/chat'
      },
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
        return InkWell(
          onTap: tool['route'] != null ? () => context.push(tool['route'] as String) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (tool['color'] as Color).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (tool['color'] as Color).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(tool['icon'] as IconData, color: tool['color'] as Color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tool['label'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
