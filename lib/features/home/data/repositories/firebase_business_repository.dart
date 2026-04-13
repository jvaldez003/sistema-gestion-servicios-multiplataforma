import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
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
              data['businessId'] = businessId; // Fix for comment path error
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
  Future<void> updateService(String businessId, String serviceId, Map<String, dynamic> service) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .update(service);
  }

  @override
  Future<void> updateProduct(String businessId, String productId, Map<String, dynamic> product) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('products')
        .doc(productId)
        .update(product);
  }

  @override
  Future<void> updatePost(String businessId, String postId, Map<String, dynamic> post) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .doc(postId)
        .update(post);
  }

  @override
  Future<void> updateTeamMember(String businessId, String memberId, Map<String, dynamic> member) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .doc(memberId)
        .update(member);
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
    final userFavoriteRef = _firestore.collection('users').doc(userId).collection('favorites').doc(businessId);

    return _firestore.runTransaction((transaction) async {
      final followerSnapshot = await transaction.get(followerRef);
      
      if (followerSnapshot.exists) {
        transaction.delete(followerRef);
        transaction.delete(userFavoriteRef);
        transaction.update(businessRef, {
          'followerCount': FieldValue.increment(-1),
        });
      } else {
        transaction.set(followerRef, {
          'followedAt': FieldValue.serverTimestamp(),
        });
        transaction.set(userFavoriteRef, {
          'businessId': businessId,
          'followedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(businessRef, {
          'followerCount': FieldValue.increment(1),
        });
      }
    });
  }

  @override
  Stream<List<Business>> getFollowedBusinessesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
      final businessIds = snapshot.docs.map((doc) => doc.id).toList();
      if (businessIds.isEmpty) return [];

      // Fetch each business doc. For production, consider caching or batching.
      final businesses = await Future.wait(
        businessIds.map((id) => _firestore.collection('businesses').doc(id).get())
      );

      return businesses
          .where((doc) => doc.exists)
          .map((doc) {
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
          })
          .toList();
    });
  }

  @override
  Future<void> sendWorkRequest(String businessId, String requesterId,
      String requesterName, String requesterAvatar) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('workRequests')
        .add({
      'businessId': businessId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterAvatar': requesterAvatar,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getWorkRequestsStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('workRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort in memory to avoid Firestore index requirement
      requests.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return requests;
    });
  }

  @override
  Future<void> acceptWorkRequest(String businessId, String requestId) async {
    final requestDoc = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('workRequests')
        .doc(requestId)
        .get();

    if (!requestDoc.exists) return;

    final data = requestDoc.data()!;
    final requesterId = data['requesterId'] as String;
    final requesterName = data['requesterName'] as String;
    final requesterAvatar = data['requesterAvatar'] as String;

    // Update request status to accepted
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('workRequests')
        .doc(requestId)
        .update({'status': 'accepted'});

    // Add to team
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .add({
      'userId': requesterId,
      'name': requesterName,
      'avatar': requesterAvatar,
      'status': 'active',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // Update professional count
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .update({
      'professionalCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> rejectWorkRequest(String businessId, String requestId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('workRequests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  @override
  Stream<bool> isMember(String businessId, String userId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('team')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  @override
  Stream<bool> hasPendingRequest(String businessId, String userId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('workRequests')
        .where('requesterId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  @override
  Future<void> likePost(String businessId, String postId, String userId) async {
    final postRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .doc(postId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final likedByUsers = List<String>.from(data['likedByUsers'] ?? []);

      if (likedByUsers.contains(userId)) {
        likedByUsers.remove(userId);
        transaction.update(postRef, {
          'likesCount': FieldValue.increment(-1),
          'likedByUsers': likedByUsers,
        });
      } else {
        likedByUsers.add(userId);
        transaction.update(postRef, {
          'likesCount': FieldValue.increment(1),
          'likedByUsers': likedByUsers,
        });
      }
    });
  }

  @override
  Future<void> addComment(
      String businessId, String postId, Map<String, dynamic> comment) async {
    final postRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .doc(postId);

    await _firestore.runTransaction((transaction) async {
      final commentRef = postRef.collection('comments').doc();
      transaction.set(commentRef, {
        ...comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(postRef, {
        'commentsCount': FieldValue.increment(1),
      });
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getCommentsStream(
      String businessId, String postId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  @override
  Stream<List<Map<String, dynamic>>> getGlobalFeedStream() {
    return _firestore
        .collectionGroup('posts')
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            data['businessId'] ??= doc.reference.parent.parent?.id;
            return data;
          }).toList();

          // Sort in memory to avoid index requirement
          posts.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return posts;
        });
  }

  @override
  Future<String> uploadImage(String path, List<int> bytes, String mimeType) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
      );
      
      final uint8List = Uint8List.fromList(bytes);
      
      // Use putData and wait for the task to complete
      final uploadTask = ref.putData(uint8List, metadata);
      
      // Monitoring task state can be helpful for debugging
      final snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      } else {
        throw Exception('Estado de subida no exitoso: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permiso denegado: Revisa las reglas de seguridad de Firebase Storage.');
      } else if (e.code == 'canceled') {
        throw Exception('Operación cancelada por el usuario o el sistema.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al subir imagen: $e');
    }
  }
}

