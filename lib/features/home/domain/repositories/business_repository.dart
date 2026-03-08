import '../../domain/models/business.dart';

abstract class BusinessRepository {
  Future<void> createBusiness(Business business);
  Future<Business?> getBusinessByOwnerId(String ownerId);
  Stream<List<Business>> getBusinessesStream();
  Future<void> addService(String businessId, Map<String, dynamic> service);
  Future<void> addProduct(String businessId, Map<String, dynamic> product);
  Future<void> addPost(String businessId, Map<String, dynamic> post);
}
