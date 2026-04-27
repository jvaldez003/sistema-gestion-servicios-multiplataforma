import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/business_repository.dart';
import '../../data/repositories/firebase_business_repository.dart';
import '../../domain/repositories/service_repository.dart';
import '../../data/repositories/firebase_service_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/firebase_product_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../data/repositories/firebase_post_repository.dart';
import '../../domain/repositories/team_repository.dart';
import '../../data/repositories/firebase_team_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return FirebaseBusinessRepository();
});

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return FirebaseServiceRepository();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirebaseProductRepository();
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return FirebasePostRepository();
});

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return FirebaseTeamRepository();
});

final businessesStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessesStream();
});
