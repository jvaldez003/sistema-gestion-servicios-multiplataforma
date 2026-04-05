import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_providers.dart';
import '../../domain/entities/app_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final AppUser? user;

  AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    AppUser? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    // Listen to auth state changes for persistence
    _repository.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.signInWithEmail(email, password);
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: 'Error al iniciar sesión');
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFirebaseError(e.toString()),
      );
    }
  }

  Future<void> signUp(String email, String password,
      {String? name, String? phoneNumber}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.signUpWithEmail(email, password,
          name: name, phoneNumber: phoneNumber);
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: 'Error al crear cuenta');
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFirebaseError(e.toString()),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFirebaseError(e.toString()),
      );
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.sendPasswordResetEmail(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFirebaseError(e.toString()),
      );
    }
  }

  String _mapFirebaseError(String error) {
    if (error.contains('invalid-credential') ||
        error.contains('user-not-found') ||
        error.contains('wrong-password')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (error.contains('email-already-in-use')) {
      return 'Este correo ya está registrado.';
    }
    if (error.contains('invalid-email')) {
      return 'El formato del correo es inválido.';
    }
    if (error.contains('weak-password')) {
      return 'La contraseña es muy débil.';
    }
    if (error.contains('operation-not-allowed')) {
      return 'El inicio de sesión con correo está desactivado.';
    }
    if (error.contains('network-request-failed')) {
      return 'Error de conexión a internet.';
    }
    if (error.contains('too-many-requests')) {
      return 'Demasiados intentos. Por favor, intenta más tarde.';
    }
    return 'Ocurrió un error inesperado. Por favor, intenta de nuevo.';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
