import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/business.dart';
import 'business_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final userFollowedBusinessesProvider = StreamProvider<List<Business>>((ref) {
  final authValue = ref.watch(authStateProvider);
  final user = authValue.value;
  if (user == null) return Stream.value([]);

  return ref.watch(businessRepositoryProvider).getFollowedBusinessesStream(user.id);
});

final userPointsProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.value?.points ?? 0;
});

final pointsHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .collection('points_history')
      .orderBy('createdAt', descending: true)
      .limit(30)
      .snapshots()
      .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
});
