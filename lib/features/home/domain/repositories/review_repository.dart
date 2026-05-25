import '../models/review.dart';

abstract class ReviewRepository {
  Stream<List<Review>> getReviews(String businessId);
  Future<void> submitReview(String businessId, Review review);
  Future<bool> hasUserReviewed(String businessId, String userId);
}
