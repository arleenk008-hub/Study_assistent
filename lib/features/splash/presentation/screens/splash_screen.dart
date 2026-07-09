import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:study_assistent/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _bookController;
  late final Animation<double> _flip;

  @override
  void initState() {
    super.initState();
    _bookController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _flip = CurvedAnimation(parent: _bookController, curve: Curves.easeInOut);
    _bookController.forward();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _bookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Book
            SizedBox(
              width: 140,
              height: 140,
              child: AnimatedBuilder(
                animation: _flip,
                builder: (context, child) {
                  final t = _flip.value; // 0.0 -> 1.0
                  // angle 0 -> pi for a single page turn
                  final angle = t * math.pi;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Back cover / spine
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.brown[700],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
                          ],
                        ),
                      ),

                      // Inner page visible when turned
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..translate(10.0, 0.0, 0.0)..rotateY(angle > math.pi / 2 ? 0.0 : 0.0),
                        child: Container(
                          width: 108,
                          height: 104,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),

                      // Page that folds/turns
                      Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..translate(6.0)
                          ..rotateY(-angle),
                        child: Container(
                          width: 108,
                          height: 104,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 3)),
                            ],
                          ),
                        ),
                      ),

                      // Subtle shine when opening
                      Opacity(
                        opacity: (t * 1.2).clamp(0.0, 1.0),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [Colors.white.withOpacity(0.06), Colors.transparent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ).animate().fadeIn().scale(duration: 800.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 24),
            Text(
              'StudyAI',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Learn Smarter with AI',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.2,
                  ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
