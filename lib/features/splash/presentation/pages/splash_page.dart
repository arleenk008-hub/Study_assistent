import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Give time for the animation
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Direct check of auth state
    final authState = ref.read(authStateProvider);
    
    // We navigate based on whether we have a user or not
    if (authState.hasValue) {
      final user = authState.value;
      if (user != null) {
        context.go(user.role.name == 'teacher' ? '/teacher-dashboard' : '/');
      } else {
        context.go('/welcome');
      }
    } else {
      // If still loading or has error, go to welcome as fallback
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              size: 100,
              color: Colors.white,
            ).animate().fade(duration: 800.ms).scale(curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            const Text(
              'Mentora',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ).animate().slideY(begin: 0.3, end: 0, duration: 800.ms).fade(),
            const SizedBox(height: 12),
            const Text(
              'Turn Knowledge Into Opportunity',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ).animate().fade(delay: 500.ms),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
