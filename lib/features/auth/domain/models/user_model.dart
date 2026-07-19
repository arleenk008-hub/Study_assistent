enum UserRole { student, teacher, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profilePicture;
  final String? phoneNumber;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
    this.phoneNumber,
    this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      profilePicture: json['profilePicture'],
      phoneNumber: json['phoneNumber'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
      'metadata': metadata,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
  
  UserModel copyWith({
    String? name,
    String? email,
    String? profilePicture,
    String? phoneNumber,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      metadata: metadata ?? this.metadata,
    );
  }
}
