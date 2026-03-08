import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'business_providers.dart';

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
