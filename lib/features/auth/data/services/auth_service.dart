import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = ApiEndpoints.login;
      if (url == null) return {'success': false, 'message': 'Backend not configured'};

      final response = await _apiClient.post(
        url,
        {'email': email, 'password': password},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_role', data['role']);
        await prefs.setString('user_id', data['_id']);
        return {'success': true};
      }
      return {
        'success': false, 
        'message': data['message'] ?? 'Invalid credentials', 
        'needsVerification': data['needsVerification'] ?? false
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: ${e.toString()}'};
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final url = ApiEndpoints.register;
      if (url == null) return {'success': false, 'message': 'Backend not configured'};

      final response = await _apiClient.post(
        url,
        {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'email': email};
      }
      return {'success': false, 'message': data['message'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: ${e.toString()}'};
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final url = ApiEndpoints.verifyOTP;
      if (url == null) return {'success': false, 'message': 'Backend not configured'};

      final response = await _apiClient.post(
        url,
        {'email': email, 'otp': otp},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_role', data['role']);
        await prefs.setString('user_id', data['_id']);
        return {'success': true};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: ${e.toString()}'};
    }
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
}
