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
