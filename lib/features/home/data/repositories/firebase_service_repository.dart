import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/service.dart';
import '../../domain/repositories/service_repository.dart';

class FirebaseServiceRepository implements ServiceRepository {
  final FirebaseFirestore _firestore;

  FirebaseServiceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addService(String businessId, Service service) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .add(service.toMap());
  }

  @override
  Future<void> updateService(String businessId, String serviceId, Service service) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .update(service.toMap());
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
  Stream<List<Service>> getServicesStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Service.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
