import '../../domain/models/business.dart';

abstract class BusinessRepository {
  Future<void> createBusiness(Business business);
  Future<Business?> getBusinessByOwnerId(String ownerId);
  Stream<Business?> getBusinessStream(String businessId);
  Stream<List<Business>> getBusinessesStream();
  Future<void> addService(String businessId, Map<String, dynamic> service);
  Future<void> addProduct(String businessId, Map<String, dynamic> product);
  Future<void> addPost(String businessId, Map<String, dynamic> post);
  Stream<List<Map<String, dynamic>>> getServicesStream(String businessId);
  Stream<List<Map<String, dynamic>>> getProductsStream(String businessId);
  Stream<List<Map<String, dynamic>>> getPostsStream(String businessId);
  Stream<List<Map<String, dynamic>>> getTeamStream(String businessId);

  Future<void> toggleFollowBusiness(String businessId, String userId);
  Stream<bool> isFollowingBusiness(String businessId, String userId);

  Future<void> deleteService(String businessId, String serviceId);
  Future<void> deleteProduct(String businessId, String productId);
  Future<void> deletePost(String businessId, String postId);

  Future<void> updateService(String businessId, String serviceId, Map<String, dynamic> service);
  Future<void> updateProduct(String businessId, String productId, Map<String, dynamic> product);
  Future<void> updatePost(String businessId, String postId, Map<String, dynamic> post);
  Future<void> updateTeamMember(String businessId, String memberId, Map<String, dynamic> member);

  // Work Request methods
  Future<void> sendWorkRequest(
      String businessId, String requesterId, String requesterName, String requesterAvatar);
  Stream<List<Map<String, dynamic>>> getWorkRequestsStream(String businessId);
  Future<void> acceptWorkRequest(String businessId, String requestId);
  Future<void> rejectWorkRequest(String businessId, String requestId);
  Stream<bool> isMember(String businessId, String userId);
  Stream<bool> hasPendingRequest(String businessId, String userId);
  
  // Image Upload
  Future<String> uploadImage(String path, List<int> bytes, String mimeType);
  Future<void> updateGalleryImages(String businessId, List<String> imageUrls);

  // Social interactions
  Future<void> likePost(String businessId, String postId, String userId);
  Future<void> addComment(String businessId, String postId, Map<String, dynamic> comment);
  Stream<List<Map<String, dynamic>>> getCommentsStream(String businessId, String postId);
  Stream<List<Map<String, dynamic>>> getGlobalFeedStream();

  // User relations
  Stream<List<Business>> getFollowedBusinessesStream(String userId);
}
