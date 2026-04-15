import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/data/repositories/auth_repository.dart';
import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/storage/secure_storage.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({UserModel? user, bool? isLoading, bool? isAuthenticated, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authRepository.getMe();
      state = AuthState(user: user, isAuthenticated: true);
    } catch (_) {
      state = const AuthState();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authRepository.login(email, password);
      state = AuthState(user: result['user'], isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authRepository.register(data);
      state = AuthState(user: result['user'], isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState();
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
final dioClientProvider = Provider<DioClient>((ref) => DioClient(ref.read(secureStorageProvider)));
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.read(dioClientProvider), ref.read(secureStorageProvider)));
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref.read(authRepositoryProvider)));
