import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository_interface.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<UserModel?> get authStateChanges => _auth.authStateChanges().asyncMap((firebaseUser) async {
    if (firebaseUser == null) return null;
    try {
      return await _getUserFromFirestore(firebaseUser.uid);
    } catch (e) {
      debugPrint('Auth Stream Error: $e');
      return null;
    }
  });

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      // Added a small timeout so it doesn't hang if permissions are wrong
      final doc = await _firestore.collection('users').doc(uid).get().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Connection timed out while fetching profile.'),
      );
      
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({...doc.data()!, 'id': uid});
      }
      return null;
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission Denied: Firebase Rules issue.');
      }
      rethrow;
    }
  }

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

      final user = await _getUserFromFirestore(credential.user!.uid);
      
      if (user == null) {
        await _auth.signOut();
        throw Exception('User details not found. Please Register.');
      }

      if (user.role != role) {
        await _auth.signOut();
        throw Exception('Access Denied: Wrong portal for your role.');
      }

      return user;
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
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
      );

      // We use merge: true to ensure we don't overwrite if it exists
      await _firestore.collection('users').doc(user.id).set(
        user.toJson(),
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 10));
      
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      if (credential?.user != null) {
        await credential!.user!.delete();
      }
      if (e.toString().contains('permission-denied')) {
        throw Exception('Registration Failed: Firebase Rules are blocking data save.');
      }
      throw Exception('Database Error: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserFromFirestore(firebaseUser.uid);
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
      return user;
    } catch (e) {
      throw Exception('Failed to update profile.');
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
