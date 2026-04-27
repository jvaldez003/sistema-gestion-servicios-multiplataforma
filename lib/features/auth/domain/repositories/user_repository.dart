import '../../domain/entities/app_user.dart';

abstract class UserRepository {
  Future<void> ensureUserDocument(AppUser user);
  Stream<AppUser?> getUserStream(String userId);
  Future<void> updateUserPoints(String userId, int points);
  Future<void> updateUserProfile(String userId, {String? name, String? email, String? photoUrl, String? phoneNumber});
}
