import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/review.dart';
import '../../domain/repositories/review_repository.dart';

class FirebaseReviewRepository implements ReviewRepository {
  final FirebaseFirestore _firestore;

  FirebaseReviewRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Review>> getReviews(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Review.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> submitReview(String businessId, Review review) async {
    final batch = _firestore.batch();

    final reviewRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('reviews')
        .doc(review.userId);

    batch.set(reviewRef, {
      ...review.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update business average rating
    final allReviews = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('reviews')
        .get();

    double total = review.rating;
    int count = 1;
    for (final doc in allReviews.docs) {
      if (doc.id != review.userId) {
        total += (doc.data()['rating'] ?? 0).toDouble();
        count++;
      }
    }
    final newAvg = double.parse((total / count).toStringAsFixed(1));

    final businessRef = _firestore.collection('businesses').doc(businessId);
    batch.update(businessRef, {'rating': newAvg, 'totalReviews': count});

    await batch.commit();
  }

  @override
  Future<bool> hasUserReviewed(String businessId, String userId) async {
    final doc = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('reviews')
        .doc(userId)
        .get();
    return doc.exists;
  }
}
