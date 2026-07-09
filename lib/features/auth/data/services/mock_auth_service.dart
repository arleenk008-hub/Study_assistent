import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart';
import 'auth_service_interface.dart';

/// Mock authentication service for local testing without backend.
/// Stores user data locally using SharedPreferences.
class MockAuthService implements AuthServiceInterface {
  static const String _usersStorageKey = 'mock_users_database';
  static const String _otpKey = 'mock_otp_storage';

  Map<String, User> _usersCache = {};
  late SharedPreferences _prefs;

  static final MockAuthService _instance = MockAuthService._internal();

  factory MockAuthService() => _instance;

  MockAuthService._internal();

  /// Initialize the service (loads users from storage)
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUsersFromStorage();
  }

  /// Load all users from local storage
  Future<void> _loadUsersFromStorage() async {
    final jsonString = _prefs.getString(_usersStorageKey);
    _usersCache = {};

    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        for (final userJson in decoded) {
          final user = User.fromJson(userJson);
          _usersCache[user.email] = user;
        }
      } catch (e) {
        _usersCache = {};
      }
    }
  }

  /// Save all users to local storage
  Future<void> _saveUsersToStorage() async {
    final jsonString =
        jsonEncode(_usersCache.values.map((u) => u.toStorageJson()).toList());
    await _prefs.setString(_usersStorageKey, jsonString);
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      email = email.toLowerCase().trim();

      if (!_usersCache.containsKey(email)) {
        return {'success': false, 'message': 'User not found. Please register first.'};
      }

      final user = _usersCache[email]!;

      if (!user.verifyPassword(password)) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      if (!user.isVerified) {
        return {
          'success': false,
          'message': 'Please verify your email first',
          'needsVerification': true
        };
      }

      final token = user.generateToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', user.role);
      await prefs.setString('user_id', user.id);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred during login'};
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      email = email.toLowerCase().trim();
      name = name.trim();

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      if (_usersCache.containsKey(email)) {
        return {
          'success': false,
          'message': 'User with this email already exists. Please login instead.'
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters long'
        };
      }

      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final user = User(
        id: userId,
        name: name,
        email: email,
        passwordHash: User.hashPassword(password),
        role: role,
        createdAt: DateTime.now(),
        isVerified: false,
      );

      _usersCache[email] = user;
      await _saveUsersToStorage();
      await _storeMockOTP(email, '123456');

      return {
        'success': true,
        'email': email,
        'userId': userId,
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred during registration'};
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      email = email.toLowerCase().trim();
      final storedOTP = _getMockOTP(email);
      
      if (otp != '123456' && otp != storedOTP) {
        return {'success': false, 'message': 'Invalid OTP. Try 123456'};
      }

      if (!_usersCache.containsKey(email)) {
        return {'success': false, 'message': 'User not found'};
      }

      final user = _usersCache[email]!;
      final verifiedUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        passwordHash: user.passwordHash,
        role: user.role,
        createdAt: user.createdAt,
        isVerified: true,
      );

      _usersCache[email] = verifiedUser;
      await _saveUsersToStorage();

      final token = verifiedUser.generateToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', verifiedUser.role);
      await prefs.setString('user_id', verifiedUser.id);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred during OTP verification'};
    }
  }

  Future<void> _storeMockOTP(String email, String otp) async {
    final otpMapStr = _prefs.getString(_otpKey);
    final otps = otpMapStr != null ? jsonDecode(otpMapStr) : {};
    otps[email.toLowerCase()] = otp;
    await _prefs.setString(_otpKey, jsonEncode(otps));
  }

  String _getMockOTP(String email) {
    try {
      final otpMapStr = _prefs.getString(_otpKey);
      if (otpMapStr != null) {
        final otps = jsonDecode(otpMapStr);
        return otps[email.toLowerCase()] ?? '123456';
      }
    } catch (_) {}
    return '123456';
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  List<User> getAllUsers() {
    return _usersCache.values.toList();
  }

  Future<void> clearAllUsers() async {
    _usersCache.clear();
    await _prefs.remove(_usersStorageKey);
    await _prefs.remove(_otpKey);
  }
}
