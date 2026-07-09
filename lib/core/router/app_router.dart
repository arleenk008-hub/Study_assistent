import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/models/user_model.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/auth_role_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/student_dashboard.dart';
import '../../features/teacher/presentation/pages/teacher_dashboard.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import 'package:study_assistent/features/notifications/presentation/pages/notifications_page.dart';
import 'package:study_assistent/features/chat/presentation/pages/chat_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final user = authState.value;
      final isSplash = state.uri.path == '/splash';
      final isLoggingIn = state.uri.path == '/login' || 
                         state.uri.path == '/register' || 
                         state.uri.path == '/auth-role';

      if (authState.isLoading) return null;

      if (user == null) {
        if (isLoggingIn || isSplash) return null;
        return '/auth-role';
      }

      if (isLoggingIn || isSplash) {
        return user.role == UserRole.teacher ? '/teacher-dashboard' : '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/auth-role',
        builder: (context, state) => const AuthRolePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] == 'teacher' 
              ? UserRole.teacher 
              : UserRole.student;
          return LoginPage(role: role);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] == 'teacher' 
              ? UserRole.teacher 
              : UserRole.student;
          return RegisterPage(role: role);
        },
      ),
      // Student Hub
      GoRoute(
        path: '/',
        builder: (context, state) => const StudentDashboard(),
      ),
      // Teacher Hub
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder:(context, state) =>
            NotificationsPage(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const
            ChatPage(),
      ),
    ],
  );
});
