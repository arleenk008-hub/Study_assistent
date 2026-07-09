import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: width ?? double.infinity,
      height: height ?? 200,
      borderRadius: borderRadius,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: AppColors.glassGradient,
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.2),
        ],
      ),
      child: child,
    );
  }
}
