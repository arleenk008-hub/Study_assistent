import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../../history/presentation/providers/history_service_provider.dart';

// Force use of Firebase - Mock repository is now completely removed from here
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Real-time stream of the authenticated user from Firebase
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Auth Controller to manage login/register actions
class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final IAuthRepository _repository;
  final Ref _ref;

  AuthController(this._ref, this._repository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password, UserRole role) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email: email, password: password, role: role);
      await _ref.read(historyServiceProvider).logAuthActivity(true);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw e; // Rethrow to catch in the UI (Login/Register pages)
    }
  }

  Future<void> register(String name, String email, String password, UserRole role) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(name: name, email: email, password: password, role: role);
      await _ref.read(historyServiceProvider).logAuthActivity(true);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw e; // Rethrow to catch in the UI
    }
  }

  Future<void> updateProfile(UserModel user) async {
    state = const AsyncValue.loading();
    try {
      final updatedUser = await _repository.updateProfile(user);
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw e;
    }
  }

  Future<void> logout() async {
    try {
      await _ref.read(historyServiceProvider).logAuthActivity(false);
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      // Ignore logout errors
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(ref, repo);
});
