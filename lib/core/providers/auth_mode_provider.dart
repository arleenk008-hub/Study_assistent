import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider to toggle between real backend and mock local authentication
final authModeProvider = StateNotifierProvider<AuthModeNotifier, AuthMode>((ref) {
  return AuthModeNotifier();
});

/// Authentication mode
enum AuthMode {
  /// Use real backend API
  backend,

  /// Use mock local authentication (for testing without backend)
  mock,
}

/// Manages authentication mode (real vs mock)
class AuthModeNotifier extends StateNotifier<AuthMode> {
  static const String _authModeKey = 'auth_mode_preference';

  AuthModeNotifier() : super(AuthMode.backend) {
    _loadAuthMode();
  }

  /// Load auth mode from preferences
  Future<void> _loadAuthMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString(_authModeKey) ?? 'backend';
      state = mode == 'mock' ? AuthMode.mock : AuthMode.backend;
    } catch (_) {
      state = AuthMode.backend;
    }
  }

  /// Switch to backend authentication
  Future<void> useBackend() async {
    state = AuthMode.backend;
    await _saveAuthMode();
  }

  /// Switch to mock authentication
  Future<void> useMock() async {
    state = AuthMode.mock;
    await _saveAuthMode();
  }

  /// Toggle between modes
  Future<void> toggle() async {
    if (state == AuthMode.backend) {
      await useMock();
    } else {
      await useBackend();
    }
  }

  /// Save auth mode to preferences
  Future<void> _saveAuthMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = state == AuthMode.mock ? 'mock' : 'backend';
      await prefs.setString(_authModeKey, modeString);
    } catch (_) {}
  }

  /// Get display name
  String get modeName => state == AuthMode.mock ? 'Mock (Testing)' : 'Backend (Production)';

  /// Check if using mock mode
  bool get isMock => state == AuthMode.mock;

  /// Check if using backend mode
  bool get isBackend => state == AuthMode.backend;
}
