import 'dart:convert';
import 'package:crypto/crypto.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String role; // 'student' or 'teacher'
  final DateTime createdAt;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    this.isVerified = false,
  });

  /// Verify password against hash
  bool verifyPassword(String password) {
    return passwordHash == User.hashPassword(password);
  }

  /// Hash password using SHA256 (mock - use bcrypt in production)
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Generate a simple mock token
  String generateToken() {
    return sha256.convert(utf8.encode('$id:$email:${DateTime.now().millisecondsSinceEpoch}')).toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      isVerified: json['isVerified'] ?? false,
    );
  }
}
