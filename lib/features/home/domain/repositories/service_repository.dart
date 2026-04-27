import '../models/service.dart';

abstract class ServiceRepository {
  Future<void> addService(String businessId, Service service);
  Future<void> updateService(String businessId, String serviceId, Service service);
  Future<void> deleteService(String businessId, String serviceId);
  Stream<List<Service>> getServicesStream(String businessId);
}
