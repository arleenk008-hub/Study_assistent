import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionHeader('PREFERENCES'),
          _buildSettingsCard(
            isDark,
            children: [
              _buildSwitchTile(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                title: 'Dark Theme',
                value: themeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ],
          ),
          
          _buildSectionHeader('NOTIFICATIONS'),
          _buildSettingsCard(
            isDark,
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                value: true,
                onChanged: (val) {},
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.auto_awesome_outlined,
                title: 'Study Reminders',
                value: true,
                onChanged: (val) {},
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.campaign_outlined,
                title: 'Live Class Alerts',
                value: false,
                onChanged: (val) {},
              ),
            ],
          ),

          _buildSectionHeader('SECURITY & PERMISSIONS'),
          _buildSettingsCard(
            isDark,
            children: [
              _buildActionTile(Icons.lock_outline_rounded, 'Privacy Settings', () {}),
              _buildDivider(),
              _buildActionTile(Icons.camera_alt_outlined, 'Camera Access', () async {
                await Permission.camera.request();
              }),
            ],
          ),

          const SizedBox(height: 30),
          _buildSettingsCard(
            isDark,
            children: [
              _buildActionTile(
                Icons.logout_rounded, 
                'Sign Out', 
                () => _showLogoutDialog(context),
                textColor: Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
      child: Text(
        title, 
        style: const TextStyle(
          color: AppColors.textSecondary, 
          fontWeight: FontWeight.w800, 
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, {required List<Widget> children}) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: (children.length * 60.0),
      borderRadius: 20,
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
          (isDark ? Colors.white10 : Colors.black12),
          Colors.transparent,
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return SizedBox(
      height: 60,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        trailing: Switch.adaptive(
          value: value, 
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {Color? textColor}) {
    return SizedBox(
      height: 60,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: textColor ?? AppColors.primary, size: 22),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor ?? Colors.white)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 0.5, color: Colors.white.withOpacity(0.05), indent: 55);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to exit?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => context.go('/auth-role'), 
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
