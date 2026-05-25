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
        phoneNumber: data['phoneNumber'],
        photoUrl: data['photoUrl'],
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

  @override
  Future<void> updateUserProfile(String userId, {String? name, String? email, String? photoUrl, String? phoneNumber}) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (data.isNotEmpty) {
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    }
  }

  @override
  Future<List<AppUser>> searchUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final Set<String> seenIds = {};
    final List<AppUser> results = [];

    AppUser toUser(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final data = doc.data();
      return AppUser(
        id: doc.id,
        email: data['email'] ?? '',
        name: data['name'],
        phoneNumber: data['phoneNumber'],
        photoUrl: data['photoUrl'],
        points: data['points'] ?? 0,
        favoriteIds: List<String>.from(data['favoriteIds'] ?? []),
      );
    }

    // Email exact match
    final byEmail = await _firestore
        .collection('users')
        .where('email', isEqualTo: trimmed.toLowerCase())
        .limit(10)
        .get();
    for (final doc in byEmail.docs) {
      if (seenIds.add(doc.id)) results.add(toUser(doc));
    }

    // Name prefix search
    final byName = await _firestore
        .collection('users')
        .orderBy('name')
        .startAt([trimmed])
        .endAt(['$trimmed'])
        .limit(10)
        .get();
    for (final doc in byName.docs) {
      if (seenIds.add(doc.id)) results.add(toUser(doc));
    }

    return results;
  }
}
