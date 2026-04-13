import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> ensureUserDocument(AppUser user) async {
    final doc = await _firestore.collection('users').doc(user.id).get();
    if (!doc.exists) {
      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'points': 0,
        'favoriteIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Stream<AppUser?> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return AppUser(
        id: doc.id,
        email: data['email'] ?? '',
        name: data['name'],
        points: data['points'] ?? 0,
        favoriteIds: List<String>.from(data['favoriteIds'] ?? []),
      );
    });
  }

  @override
  Future<void> updateUserPoints(String userId, int points) async {
    await _firestore.collection('users').doc(userId).update({
      'points': FieldValue.increment(points),
    });
  }
}
