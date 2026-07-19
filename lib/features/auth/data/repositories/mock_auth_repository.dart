import 'dart:async';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository_interface.dart';

class MockAuthRepository implements IAuthRepository {
  final _controller = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  MockAuthRepository() {
    // Initial state
    _controller.add(null);
  }

  @override
  Stream<UserModel?> get authStateChanges => _controller.stream;

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    if (email.contains('error')) {
      throw Exception('Invalid credentials provided.');
    }

    // Extracting a name from email for a more personalized feel
    final nameFromEmail = email.split('@').first;
    final formattedName = nameFromEmail.isEmpty 
        ? (role == UserRole.student ? 'Student' : 'Teacher')
        : nameFromEmail[0].toUpperCase() + nameFromEmail.substring(1);

    _currentUser = UserModel(
      id: 'mock_id_${role.name}',
      name: formattedName,
      email: email,
      role: role,
      profilePicture: 'https://i.pravatar.cc/150?u=${email}',
    );

    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'mock_reg_id',
      name: name,
      email: email,
      role: role,
    );

    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = user;
    _controller.add(_currentUser);
    return _currentUser!;
  }
}
