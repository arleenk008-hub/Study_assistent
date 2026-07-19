import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> login({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<void> logout();
  
  Future<UserModel?> getCurrentUser();
  
  Stream<UserModel?> get authStateChanges;

  Future<UserModel> updateProfile(UserModel user);
}
