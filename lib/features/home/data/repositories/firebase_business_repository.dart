import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/business.dart';
import '../../domain/repositories/business_repository.dart';

class FirebaseBusinessRepository implements BusinessRepository {
  final FirebaseFirestore _firestore;

  FirebaseBusinessRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createBusiness(Business business) async {
    await _firestore.collection('businesses').doc(business.id).set({
      'name': business.name,
      'category': business.category,
      'description': business.description,
      'imageUrl': business.imageUrl,
      'avatarUrl': business.avatarUrl,
      'rating': business.rating,
      'totalReviews': business.totalReviews,
      'distance': business.distance,
      'isVerified': business.isVerified,
      'isTop': business.isTop,
      'startingPrice': business.startingPrice,
      'tags': business.tags,
      'likes': business.likes,
      'comments': business.comments,
      'professionalCount': business.professionalCount,
      'ownerId':
          business.id, // Using business.id as surrogate for ownerId for now
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Business?> getBusinessByOwnerId(String ownerId) async {
    final snapshot = await _firestore
        .collection('businesses')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    // In a real app, you'd have a fromMap method in the Business model
    // For now, returning a mock or constructing it manually
    return null;
  }

  @override
  Stream<List<Business>> getBusinessesStream() {
    return _firestore.collection('businesses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Business(
          id: doc.id,
          name: data['name'] ?? '',
          category: data['category'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ??
              'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=800',
          avatarUrl: data['avatarUrl'] ??
              'https://ui-avatars.com/api/?name=${data['name']}',
          rating: (data['rating'] ?? 0.0).toDouble(),
          totalReviews: data['totalReviews'] ?? 0,
          distance: (data['distance'] ?? 0.0).toDouble(),
          isVerified: data['isVerified'] ?? false,
          isTop: data['isTop'] ?? false,
          startingPrice: (data['startingPrice'] ?? 0.0).toDouble(),
          tags: List<String>.from(data['tags'] ?? []),
          likes: data['likes'] ?? 0,
          comments: data['comments'] ?? 0,
          professionalCount: data['professionalCount'] ?? 0,
        );
      }).toList();
    });
  }

  @override
  Future<void> addService(
      String businessId, Map<String, dynamic> service) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .add(service);
  }

  @override
  Future<void> addProduct(
      String businessId, Map<String, dynamic> product) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('products')
        .add(product);
  }

  @override
  Future<void> addPost(String businessId, Map<String, dynamic> post) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .add(post);
  }
}
