import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:study_assistent/core/router/app_router.dart';
import 'package:study_assistent/core/theme/app_theme.dart';
import 'package:study_assistent/core/providers/theme_provider.dart';
import 'package:study_assistent/core/services/notification_service.dart';
import 'package:study_assistent/firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase but don't crash if it fails
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase not configured yet: $e');
  }

  // 2. Initialize Hive
  await Hive.initFlutter();
  try {
    await Hive.openBox('study_history_cache');
    await Hive.openBox('offline_history');
    await Hive.openBox('achievements');
  } catch (e) {
    debugPrint('Hive Init Error: $e');
  }
  
  // 3. Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(
    const ProviderScope(
      child: MentoraApp(),
    ),
  );
}

class MentoraApp extends ConsumerWidget {
  const MentoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Mentora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
