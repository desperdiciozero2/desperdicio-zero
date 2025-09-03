import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// Provider para o AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final authService = AuthService();
  authService.initialize();
  return authService;
});

// Estados de autenticação
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Notifier para gerenciar o estado de autenticação
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthInitial()) {
    // Configura o listener de mudanças de estado de autenticação
    _authService.authStateChanges.listen((user) {
      state = user != null ? Authenticated(user) : Unauthenticated();
    });
  }

  // Login com email e senha
  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = AuthLoading();
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
    } catch (e) {
      state = AuthError(e.toString());
      rethrow;
    }
  }

  // Cadastro com email e senha
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      state = AuthLoading();
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
    } catch (e) {
      state = AuthError(e.toString());
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      state = AuthLoading();
      await _authService.signOut();
    } catch (e) {
      state = AuthError(e.toString());
      rethrow;
    }
  }

  // Esqueci a senha
  Future<void> resetPassword(String email) async {
    try {
      state = AuthLoading();
      await _authService.resetPassword(email);
    } catch (e) {
      state = AuthError(e.toString());
      rethrow;
    }
  }
}

// Provider para o AuthNotifier
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Provider para acessar o usuário atual
final currentUserProvider = Provider<User?>((ref) {
  final state = ref.watch(authStateProvider);
  return state is Authenticated ? state.user : null;
});

// Provider para verificar se o usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(authStateProvider);
  return state is Authenticated;
});
