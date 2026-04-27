abstract class PostRepository {
  Future<void> addPost(String businessId, Map<String, dynamic> post);
  Future<void> updatePost(String businessId, String postId, Map<String, dynamic> post);
  Future<void> deletePost(String businessId, String postId);
  Stream<List<Map<String, dynamic>>> getPostsStream(String businessId);
  Future<void> likePost(String businessId, String postId, String userId);
  Future<void> addComment(String businessId, String postId, Map<String, dynamic> comment);
  Stream<List<Map<String, dynamic>>> getCommentsStream(String businessId, String postId);
  Stream<List<Map<String, dynamic>>> getGlobalFeedStream();
}
