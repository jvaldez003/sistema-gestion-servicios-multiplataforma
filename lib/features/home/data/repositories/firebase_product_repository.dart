import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/product_repository.dart';

class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;

  FirebaseProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addProduct(String businessId, Map<String, dynamic> product) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('products')
        .add(product);
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
  Future<void> deleteProduct(String businessId, String productId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('products')
        .doc(productId)
        .delete();
  }

  @override
  Stream<List<Map<String, dynamic>>> getProductsStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }
}
