import 'backend_config.dart';

class ApiEndpoints {
  // Get the configured base URL. Returns null if not configured.
  static String? get baseUrl {
    final config = BackendConfig();
    return config.baseUrl;
  }

  static String? get login {
    final base = baseUrl;
    return base != null ? '$base/auth/login' : null;
  }

  static String? get register {
    final base = baseUrl;
    return base != null ? '$base/auth/register' : null;
  }

  static String? get verifyOTP {
    final base = baseUrl;
    return base != null ? '$base/auth/verify-otp' : null;
  }

  static String? get aiChat {
    final base = baseUrl;
    return base != null ? '$base/ai/chat' : null;
  }

  static String? get teachers {
    final base = baseUrl;
    return base != null ? '$base/teachers' : null;
  }

  static String? get notes {
    final base = baseUrl;
    return base != null ? '$base/notes' : null;
  }

  static String? get papers {
    final base = baseUrl;
    return base != null ? '$base/papers' : null;
  }

  static String? get credits {
    final base = baseUrl;
    return base != null ? '$base/credits' : null;
  }
}
