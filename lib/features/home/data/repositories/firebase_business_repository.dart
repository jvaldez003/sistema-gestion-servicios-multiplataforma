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
      'followerCount': business.followerCount,
      'galleryImages': business.galleryImages,
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

    final doc = snapshot.docs.first;
    final data = doc.data();
    return Business(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
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
      followerCount: data['followerCount'] ?? 0,
      galleryImages: List<String>.from(data['galleryImages'] ?? []),
    );
  }

  @override
  Stream<Business?> getBusinessStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return Business(
        id: doc.id,
        name: data['name'] ?? '',
        category: data['category'] ?? '',
        description: data['description'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        avatarUrl: data['avatarUrl'] ?? '',
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
        followerCount: data['followerCount'] ?? 0,
        galleryImages: List<String>.from(data['galleryImages'] ?? []),
      );
    });
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
          imageUrl: data['imageUrl'] ?? '',
          avatarUrl: data['avatarUrl'] ?? '',
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
          followerCount: data['followerCount'] ?? 0,
          galleryImages: List<String>.from(data['galleryImages'] ?? []),
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
        .add({
      ...post,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getServicesStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> getProductsStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> getPostsStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Future<void> updateGalleryImages(
      String businessId, List<String> imageUrls) async {
    await _firestore.collection('businesses').doc(businessId).update({
      'galleryImages': imageUrls,
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getTeamStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  @override
  Future<void> deleteService(String businessId, String serviceId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .delete();
  }

  @override
  Future<void> deleteProduct(String businessId, String productId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('products')
        .doc(productId)
        .delete();
  }

  @override
  Future<void> deletePost(String businessId, String postId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .doc(postId)
        .delete();
  }

  @override
  Stream<bool> isFollowingBusiness(String businessId, String userId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('followers')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  @override
  Future<void> toggleFollowBusiness(String businessId, String userId) async {
    final businessRef = _firestore.collection('businesses').doc(businessId);
    final followerRef = businessRef.collection('followers').doc(userId);

    return _firestore.runTransaction((transaction) async {
      final followerSnapshot = await transaction.get(followerRef);
      
      if (followerSnapshot.exists) {
        transaction.delete(followerRef);
        transaction.update(businessRef, {
          'followerCount': FieldValue.increment(-1),
        });
      } else {
        transaction.set(followerRef, {
          'followedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(businessRef, {
          'followerCount': FieldValue.increment(1),
        });
      }
    });
  }
}
