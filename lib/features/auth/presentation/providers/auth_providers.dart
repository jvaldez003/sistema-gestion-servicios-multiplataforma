import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../data/repositories/firebase_user_repository.dart';
import '../../domain/repositories/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProfileProvider = StreamProvider<AppUser?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);
  
  return ref.watch(userRepositoryProvider).getUserStream(authUser.id).map((firestoreUser) {
    if (firestoreUser != null) {
      return AppUser(
        id: firestoreUser.id,
        email: firestoreUser.email.isNotEmpty ? firestoreUser.email : authUser.email,
        name: firestoreUser.name ?? authUser.name,
        photoUrl: firestoreUser.photoUrl ?? authUser.photoUrl,
        phoneNumber: firestoreUser.phoneNumber ?? authUser.phoneNumber,
        points: firestoreUser.points,
        favoriteIds: firestoreUser.favoriteIds,
      );
    }
    return authUser;
  });
});
