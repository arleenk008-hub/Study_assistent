import 'auth_service.dart';
import 'mock_auth_service.dart';
import 'auth_service_interface.dart';
import '../../../../core/providers/auth_mode_provider.dart';

/// Factory for getting the appropriate authentication service
/// Returns MockAuthService or AuthService based on configuration
class AuthServiceFactory {
  static AuthMode _currentMode = AuthMode.mock;

  /// Initialize the factory with the current auth mode
  static void setAuthMode(AuthMode mode) {
    _currentMode = mode;
  }

  /// Get the appropriate auth service based on current mode
  static AuthServiceInterface getAuthService() {
    if (_currentMode == AuthMode.mock) {
      return MockAuthService();
    } else {
      return AuthService();
    }
  }

  /// Create an auth service explicitly for mock mode
  static AuthServiceInterface getMockAuthService() {
    return MockAuthService();
  }

  /// Create an auth service explicitly for backend mode
  static AuthServiceInterface getBackendAuthService() {
    return AuthService();
  }
}
