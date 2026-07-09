import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:study_assistent/core/theme/app_colors.dart';

class NotificationShimmer extends StatefulWidget {
  const NotificationShimmer({super.key});

  @override
  State<NotificationShimmer> createState() => _NotificationShimmerState();
}

class _NotificationShimmerState extends State<NotificationShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 110,
          borderRadius: 24,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [
              (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              (isDark ? Colors.white : Colors.black).withOpacity(0.02),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              (isDark ? Colors.white24 : Colors.black12),
              Colors.transparent,
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildShimmerCircle(isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerLine(isDark, width: 80, height: 10),
                      const SizedBox(height: 8),
                      _buildShimmerLine(isDark, width: 180, height: 14),
                      const SizedBox(height: 6),
                      _buildShimmerLine(isDark, width: 140, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCircle(bool isDark) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: _getShimmerGradient(isDark),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLine(bool isDark, {required double width, required double height}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: _getShimmerGradient(isDark),
          ),
        );
      },
    );
  }

  LinearGradient _getShimmerGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        (isDark ? Colors.white12 : Colors.black.withOpacity(0.05)),
        (isDark ? Colors.white24 : Colors.black.withOpacity(0.1)),
        (isDark ? Colors.white12 : Colors.black.withOpacity(0.05)),
      ],
      stops: [
        0.0,
        _animationController.value,
        1.0,
      ],
    );
  }
}
