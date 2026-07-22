import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/models/user_model.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/auth_role_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/home/presentation/pages/student_dashboard.dart';
import '../../features/teacher/presentation/pages/teacher_dashboard.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/student_edit_profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import 'package:study_assistent/features/notifications/presentation/pages/notifications_page.dart';
import 'package:study_assistent/features/chat/presentation/pages/chat_page.dart';
import 'package:study_assistent/features/search/presentation/pages/search_page.dart';
import 'package:study_assistent/features/notes/presentation/pages/notes_page.dart';
import 'package:study_assistent/features/videos/presentation/pages/video_lectures_page.dart';
import 'package:study_assistent/features/teacher/presentation/pages/teacher_profile_page.dart';
import 'package:study_assistent/features/teacher/presentation/pages/teacher_edit_profile_page.dart';
import 'package:study_assistent/features/teacher/presentation/pages/student_requests_page.dart';
import 'package:study_assistent/features/notes/presentation/pages/add_note_page.dart';

// RouterNotifier helps GoRouter react to Auth state changes
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = ChangeNotifierProvider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  // Use ref.read for the notifier to keep the GoRouter instance stable
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authValue = ref.read(authStateProvider);
      final user = authValue.value;
      
      final isSplash = state.uri.path == '/splash';
      final isWelcome = state.uri.path == '/welcome';
      final isAuth = state.uri.path == '/login' || 
                    state.uri.path == '/register' || 
                    state.uri.path == '/auth-role';

      // Stay on Splash while loading the initial auth state
      if (authValue.isLoading && isSplash) return null;

      if (user == null) {
        // Not logged in: allow splash, welcome, and auth pages, else redirect to welcome
        if (isSplash || isWelcome || isAuth) return null;
        return '/welcome';
      }

      // Logged in: if on an auth-related page, redirect to correct dashboard
      if (isSplash || isWelcome || isAuth) {
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
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
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
      GoRoute(
        path: '/',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const StudentEditProfilePage(),
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
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return SearchPage(initialCategory: category);
        },
      ),
      GoRoute(
        path: '/notes',
        builder: (context, state) => const NotesPage(),
      ),
      GoRoute(
        path: '/add-note',
        builder: (context, state) => const AddNotePage(),
      ),
      GoRoute(
        path: '/videos',
        builder: (context, state) => const VideoLecturesPage(),
      ),
      GoRoute(
        path: '/teacher/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TeacherProfilePage(teacherId: id);
        },
      ),
      GoRoute(
        path: '/teacher-edit-profile',
        builder: (context, state) => const TeacherEditProfilePage(),
      ),
      GoRoute(
        path: '/student-requests',
        builder: (context, state) => const StudentRequestsPage(),
      ),
    ],
  );
});
