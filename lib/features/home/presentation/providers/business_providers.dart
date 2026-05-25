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
import '../../domain/repositories/review_repository.dart';
import '../../data/repositories/firebase_review_repository.dart';
import '../../domain/models/review.dart';
import '../../domain/models/business.dart';

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

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return FirebaseReviewRepository();
});

final businessReviewsProvider = StreamProvider.family<List<Review>, String>((ref, businessId) {
  return ref.watch(reviewRepositoryProvider).getReviews(businessId);
});

final businessesStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessesStream();
});

// Filter state
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final ratingFilterProvider = StateProvider<double>((ref) => 0.0);

final filteredBusinessesProvider = Provider<List<Business>>((ref) {
  final businessesAsync = ref.watch(businessesStreamProvider);
  final category = ref.watch(categoryFilterProvider);
  final minRating = ref.watch(ratingFilterProvider);
  final all = businessesAsync.valueOrNull ?? [];
  return all.where((b) {
    if (category != null && category.isNotEmpty) {
      final cat = category.toLowerCase();
      if (!b.category.toLowerCase().contains(cat) && !b.name.toLowerCase().contains(cat)) {
        return false;
      }
    }
    if (minRating > 0 && b.rating < minRating) return false;
    return true;
  }).toList();
});
