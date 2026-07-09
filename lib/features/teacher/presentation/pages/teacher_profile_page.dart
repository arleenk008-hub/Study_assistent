import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/teacher_provider.dart';
import '../../domain/models/teacher_model.dart';

class TeacherProfilePage extends ConsumerWidget {
  final String teacherId;
  const TeacherProfilePage({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacherAsync = ref.watch(teacherDetailProvider(teacherId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: teacherAsync.when(
        data: (teacher) => CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, teacher),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(teacher),
                    const SizedBox(height: 32),
                    _buildSectionTitle('About'),
                    const SizedBox(height: 8),
                    Text(
                      teacher.bio,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                            height: 1.6,
                          ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Subjects'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: teacher.subjects.map((s) => _buildChip(s, isDark)).toList(),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Availability'),
                    const SizedBox(height: 12),
                    _buildAvailability(teacher, isDark),
                    const SizedBox(height: 40),
                    _buildPricingSection(teacher, isDark),
                    const SizedBox(height: 40),
                    _buildReviewsSection(teacher, isDark),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomSheet: teacherAsync.maybeWhen(
        data: (teacher) => _buildBottomAction(context, teacher),
        orElse: () => null,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TeacherProfile teacher) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (teacher.profilePicture != null)
              Image.network(teacher.profilePicture!, fit: BoxFit.cover)
            else
              Container(color: AppColors.primary),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    teacher.qualification,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(TeacherProfile teacher) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(teacher.averageRating.toString(), 'Rating', Icons.star_rounded, Colors.amber),
        _buildStatItem('${teacher.experience}Y', 'Exp.', Icons.work_history_rounded, Colors.blue),
        _buildStatItem(teacher.totalReviews.toString(), 'Reviews', Icons.reviews_rounded, Colors.green),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildAvailability(TeacherProfile teacher, bool isDark) {
    return Column(
      children: teacher.availability.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(width: 80, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: e.value.map((time) => Text(time, style: const TextStyle(color: Colors.grey))).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPricingSection(TeacherProfile teacher, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Services & Pricing'),
        const SizedBox(height: 16),
        _buildPriceItem('1-on-1 Session', teacher.pricing.oneToOne, Icons.person_add_rounded),
        _buildPriceItem('Live Class', teacher.pricing.liveClass, Icons.videocam_rounded),
        _buildPriceItem('Audio Consultation', teacher.pricing.audioCall, Icons.call_rounded),
        _buildPriceItem('Doubt Resolution (Chat)', teacher.pricing.chat, Icons.chat_rounded),
      ],
    );
  }

  Widget _buildPriceItem(String service, double price, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(service, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text('₹${price.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(TeacherProfile teacher, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Student Feedback'),
            TextButton(onPressed: () {}, child: const Text('See All')),
          ],
        ),
        const SizedBox(height: 16),
        // Mock Review
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 16, child: Text('A')),
                  const SizedBox(width: 12),
                  const Text('Aman Deep', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Row(
                    children: List.generate(5, (i) => const Icon(Icons.star, size: 14, color: Colors.amber)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Excellent teaching style. The way Dr. Sarah explains complex integration problems is just amazing.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, TeacherProfile teacher) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).surfaceTintColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Send Message'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Book Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
