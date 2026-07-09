import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'backend_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  /// Validates that backend is configured before making requests
  bool _isBackendConfigured() {
    return BackendConfig().isConfigured;
  }

  /// Gets error message when backend is not configured
  String _getUnconfiguredError() {
    return BackendConfig().getUnconfiguredErrorMessage();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    if (!_isBackendConfigured()) {
      throw Exception(_getUnconfiguredError());
    }

    final headers = await _getHeaders();
    return await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint) async {
    if (!_isBackendConfigured()) {
      throw Exception(_getUnconfiguredError());
    }

    final headers = await _getHeaders();
    return await http.get(
      Uri.parse(endpoint),
      headers: headers,
    );
  }
}
