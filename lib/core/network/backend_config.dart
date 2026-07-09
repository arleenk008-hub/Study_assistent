import 'package:shared_preferences/shared_preferences.dart';

class BackendConfig {
  static final BackendConfig _instance = BackendConfig._internal();
  factory BackendConfig() => _instance;
  BackendConfig._internal();

  static const String _baseUrlKey = 'backend_base_url';
  
  // Default URL for Android Emulator
  static const String defaultUrl = 'http://10.0.2.2:5000/api';

  bool _isConfigured = false;
  String? _cachedBaseUrl;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedBaseUrl = prefs.getString(_baseUrlKey);
    
    // If not set, use default
    if (_cachedBaseUrl == null) {
      _cachedBaseUrl = defaultUrl;
      _isConfigured = true; // Auto-configure on first run
    } else {
      _isConfigured = _cachedBaseUrl!.isNotEmpty;
    }
  }

  bool get isConfigured => _isConfigured;
  String? get baseUrl => _cachedBaseUrl;

  Future<bool> configure(String baseUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_baseUrlKey, baseUrl.trim());
      _cachedBaseUrl = baseUrl.trim();
      _isConfigured = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  String getUnconfiguredErrorMessage() {
    return 'Backend is not reachable. Please start your Node.js server.';
  }
}
