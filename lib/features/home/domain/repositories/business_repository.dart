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
}
