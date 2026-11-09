// mobile/lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../models/profile_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _service;

  AuthNotifier(this._service) : super(AuthState.initial());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _service.signIn(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = AuthState.initial().copyWith(status: AuthStatus.unauthenticated);
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return AuthNotifier(service);
});
