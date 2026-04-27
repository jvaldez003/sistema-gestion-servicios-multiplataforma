abstract class ProductRepository {
  Future<void> addProduct(String businessId, Map<String, dynamic> product);
  Future<void> updateProduct(String businessId, String productId, Map<String, dynamic> product);
  Future<void> deleteProduct(String businessId, String productId);
  Stream<List<Map<String, dynamic>>> getProductsStream(String businessId);
}
