import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/business.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/business_providers.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/auth/presentation/providers/auth_notifier.dart';

final adminBusinessProvider = FutureProvider<Business?>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.user?.id;

  if (userId == null) return null;

  return await repository.getBusinessByOwnerId(userId);
});

final adminServicesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  final businessAsync = ref.watch(adminBusinessProvider);

  return businessAsync.when(
    data: (business) {
      if (business == null) return Stream.value([]);
      return repository.getServicesStream(business.id);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});

final adminProductsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  final businessAsync = ref.watch(adminBusinessProvider);

  return businessAsync.when(
    data: (business) {
      if (business == null) return Stream.value([]);
      return repository.getProductsStream(business.id);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});

final adminPostsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  final businessAsync = ref.watch(adminBusinessProvider);

  return businessAsync.when(
    data: (business) {
      if (business == null) return Stream.value([]);
      return repository.getPostsStream(business.id);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});
