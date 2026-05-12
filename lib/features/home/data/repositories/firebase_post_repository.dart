import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/post_repository.dart';

class FirebasePostRepository implements PostRepository {
  final FirebaseFirestore _firestore;

  FirebasePostRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addPost(String businessId, Map<String, dynamic> post) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .add(post);
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
  Future<void> deletePost(String businessId, String postId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .doc(postId)
        .delete();
  }

  @override
  Stream<List<Map<String, dynamic>>> getPostsStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  @override
  Future<void> likePost(String businessId, String postId, String userId) async {
    final docRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .doc(postId);
    
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final likes = List<String>.from(data['likedByUsers'] ?? []);
    
    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await docRef.update({
      'likedByUsers': likes,
      'likesCount': likes.length,
    });
  }

  @override
  Future<void> addComment(String businessId, String postId, Map<String, dynamic> comment) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(comment);
  }

  @override
  Stream<List<Map<String, dynamic>>> getCommentsStream(String businessId, String postId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  @override
  Stream<List<Map<String, dynamic>>> getGlobalFeedStream() {
    return _firestore.collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final parentDoc = doc.reference.parent.parent;
              return {
                ...doc.data(), 
                'id': doc.id,
                'businessId': parentDoc?.id,
              };
            }).toList());
  }
}
