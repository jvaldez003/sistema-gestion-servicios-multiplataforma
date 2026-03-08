import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;

  Future<AppUser?> signInWithEmail(String email, String password);

  Future<AppUser?> signUpWithEmail(String email, String password,
      {String? name, String? phoneNumber});

  Future<AppUser?> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}
