import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository_interface.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Controller to handle Auth states
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();

  FirebaseAuthRepository() {
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        _authStateController.add(null);
      } else {
        _authStateController.add(_mapFirebaseUserToUserModel(firebaseUser));
      }
    });
  }

  // Helper to map Firebase User to our internal UserModel
  // We use displayName to store "Name|role" to avoid using Firestore
  UserModel _mapFirebaseUserToUserModel(User firebaseUser, [UserRole? roleOverride]) {
    final displayName = firebaseUser.displayName ?? "";
    final parts = displayName.split('|');
    
    // Extract name (default to email prefix if empty)
    final name = parts.isNotEmpty && parts[0].isNotEmpty 
        ? parts[0] 
        : (firebaseUser.email?.split('@')[0] ?? "User");
    
    // Extract role (default to student)
    UserRole role = UserRole.student;
    if (roleOverride != null) {
      role = roleOverride;
    } else if (parts.length > 1) {
      final roleStr = parts[1].toLowerCase();
      if (roleStr == 'teacher') role = UserRole.teacher;
      if (roleStr == 'admin') role = UserRole.admin;
    }

    return UserModel(
      id: firebaseUser.uid,
      name: name,
      email: firebaseUser.email ?? "",
      role: role,
      profilePicture: firebaseUser.photoURL,
    );
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      final userModel = _mapFirebaseUserToUserModel(credential.user!);
      
      // Role validation: ensures user is logging into the correct portal
      if (userModel.role != role) {
        await _auth.signOut();
        throw Exception('Incorrect portal. You are registered as a ${userModel.role.name}.');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // Save name and role in the displayName field to avoid Firestore
      // Format: "Name|role"
      await credential.user?.updateDisplayName("$name|${role.name}");
      
      // Reload user to ensure displayName is updated in the object
      await credential.user?.reload();
      final updatedUser = _auth.currentUser!;

      return _mapFirebaseUserToUserModel(updatedUser, role);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Registration failed. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    _authStateController.add(null);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _mapFirebaseUserToUserModel(firebaseUser);
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Update persisted name and role in displayName
        await firebaseUser.updateDisplayName("${user.name}|${user.role.name}");
        if (user.profilePicture != null) {
          await firebaseUser.updatePhotoURL(user.profilePicture);
        }
        await firebaseUser.reload();
      }
      return user;
    } catch (e) {
      throw Exception('Failed to update profile.');
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email already registered.';
      case 'invalid-email': return 'Invalid email format.';
      case 'weak-password': return 'Password must be 6+ characters.';
      case 'network-request-failed': return 'No internet connection.';
      default: return e.message ?? 'Authentication failed.';
    }
  }
}
