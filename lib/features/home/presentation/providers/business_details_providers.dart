import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import 'business_providers.dart';
import '../../domain/models/business.dart';

final businessStreamProvider = StreamProvider.family<Business?, String>((ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessStream(businessId);
});

final businessServicesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getServicesStream(businessId);
});

final businessProductsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getProductsStream(businessId);
});

final businessPostsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getPostsStream(businessId);
});

final businessTeamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getTeamStream(businessId);
});

final isFollowingBusinessProvider = StreamProvider.family<bool, String>((ref, businessId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);
  final repository = ref.watch(businessRepositoryProvider);
  return repository.isFollowingBusiness(businessId, user.id);
});
