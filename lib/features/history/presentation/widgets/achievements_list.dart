import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/achievement.dart';
import '../providers/history_providers.dart';
import '../../data/services/achievement_service.dart';
import '../../../../core/theme/app_colors.dart';

class AchievementsList extends ConsumerWidget {
  const AchievementsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Achievement>>(
      future: AchievementService().getAchievements(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final achievements = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Achievements & Badges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final a = achievements[index];
                return _buildAchievementCard(a, isDark);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement a, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: a.isUnlocked 
              ? AppColors.primary.withOpacity(0.5) 
              : (isDark ? Colors.white10 : Colors.grey[200]!),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            a.icon,
            style: TextStyle(
              fontSize: 32,
              color: a.isUnlocked ? null : Colors.grey.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            a.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: a.isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              a.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white38 : Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          _buildProgressBar(a.progress, a.isUnlocked),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, bool isUnlocked) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isUnlocked ? AppColors.success : AppColors.primary,
            ),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isUnlocked ? 'Unlocked!' : '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isUnlocked ? AppColors.success : Colors.grey,
          ),
        ),
      ],
    );
  }
}
