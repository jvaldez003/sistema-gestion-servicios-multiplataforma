import '../../domain/models/business.dart';

abstract class BusinessRepository {
  Future<void> createBusiness(Business business);
  Future<Business?> getBusinessByOwnerId(String ownerId);
  Stream<Business?> getBusinessStream(String businessId);
  Stream<List<Business>> getBusinessesStream();

  Future<void> toggleFollowBusiness(String businessId, String userId);
  Stream<bool> isFollowingBusiness(String businessId, String userId);
  
  // Image Upload
  Future<String> uploadImage(String path, List<int> bytes, String mimeType);
  Future<void> updateGalleryImages(String businessId, List<String> imageUrls);

  // User relations
  Stream<List<Business>> getFollowedBusinessesStream(String userId);
  Stream<List<Business>> getBusinessesByMemberId(String userId);
}
