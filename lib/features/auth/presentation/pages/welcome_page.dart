import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 24),
              
              const Text(
                'Mentora',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 12),
              
              Text(
                'Turn Knowledge Into Opportunity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ).animate().fadeIn(delay: 400.ms),
              
              const Spacer(),
              
              // Buttons
              _buildButton(
                context, 
                '👨‍🎓 Continue as Student', 
                () => context.push('/register?role=student'),
                true
              ).animate().slideY(begin: 0.3, end: 0, delay: 600.ms).fadeIn(),
              
              const SizedBox(height: 16),
              
              _buildButton(
                context, 
                '👨‍🏫 Continue as Teacher', 
                () => context.push('/register?role=teacher'),
                false
              ).animate().slideY(begin: 0.3, end: 0, delay: 700.ms).fadeIn(),
              
              const SizedBox(height: 40),
              
              // Bottom links
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => context.push('/login'),
                    child: const Text(
                      'Log In',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 900.ms),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback onTap, bool primary) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? AppColors.primary : Colors.transparent,
          foregroundColor: primary ? Colors.white : AppColors.primary,
          elevation: primary ? 2 : 0,
          side: primary ? null : const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
