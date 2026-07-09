import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

// Using absolute package imports to fix compiler path resolution errors
import 'package:study_assistent/core/router/app_router.dart';
import 'package:study_assistent/core/theme/app_theme.dart';
import 'package:study_assistent/core/providers/theme_provider.dart';
import 'package:study_assistent/core/providers/auth_mode_provider.dart';
import 'package:study_assistent/core/services/notification_service.dart';
import 'package:study_assistent/features/auth/data/services/auth_service_factory.dart';
import 'package:study_assistent/firebase_options.dart'; 

void main() async {
  // Required to allow native code communication before runApp()
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase successfully initialized');
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  // 2. Initialize Hive for local storage and caching
  await Hive.initFlutter();
  await Hive.openBox('study_history_cache');
  await Hive.openBox('offline_history');
  await Hive.openBox('achievements');
  
  // 3. Initialize App-wide Configurations
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(
    const ProviderScope(
      child: StudyAIApp(),
    ),
  );
}

class StudyAIApp extends ConsumerWidget {
  const StudyAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    
    // Synchronize Auth Mode (Mock vs Server)
    final authMode = ref.watch(authModeProvider);
    AuthServiceFactory.setAuthMode(authMode);

    return MaterialApp.router(
      title: 'StudyAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
