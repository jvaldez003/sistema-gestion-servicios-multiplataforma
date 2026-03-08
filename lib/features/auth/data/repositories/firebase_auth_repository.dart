import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '178817144351-4q7cmog0nmjusb9dcrn6ke3p19mqavgl.apps.googleusercontent.com',
  );

  AppUser? _userFromFirebase(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
    );
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(userCredential.user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser?> signUpWithEmail(String email, String password,
      {String? name, String? phoneNumber}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (name != null) {
        await userCredential.user?.updateDisplayName(name);
      }

      // Note: Updating phone number requires verification usually,
      // but we can store it in Firestore later during the profile step.

      return _userFromFirebase(userCredential.user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return _userFromFirebase(userCredential.user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
