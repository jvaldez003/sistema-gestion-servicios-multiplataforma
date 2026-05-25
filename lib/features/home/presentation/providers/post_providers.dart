import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/post.dart';
import '../../domain/models/business.dart';
import 'business_providers.dart';
import '../../domain/repositories/post_repository.dart';

final globalFeedProvider = StreamProvider<List<BusinessPost>>((ref) {
  final repo = ref.watch(postRepositoryProvider);
  return repo.getGlobalFeedStream().asyncMap((maps) async {
    final List<BusinessPost> posts = [];

    // Fetch all businesses once to avoid multiple stream subscriptions in the loop
    final allBusinesses =
        await ref.read(businessRepositoryProvider).getBusinessesStream().first;

    for (final map in maps) {
      final String? businessId = map['businessId'];
      if (businessId == null || businessId.isEmpty) continue;

      // Find the business in the pre-fetched list
      final business = allBusinesses.firstWhere(
        (b) => b.id == businessId,
        orElse: () => Business(
          id: businessId,
          name: 'Negocio',
          category: 'Servicios',
          description: 'Cargando información del negocio...',
          imageUrl: '',
          avatarUrl: '',
          rating: 5.0,
          totalReviews: 0,
          distance: 0.0,
          startingPrice: 0.0,
          tags: [],
        ),
      );

      posts.add(BusinessPost.fromMap(
        map['id'],
        map,
        businessName: business.name,
        businessAvatar: business.avatarUrl,
      ));
    }
    return posts;
  });
});

class CommentArgs {
  final String businessId;
  final String postId;
  CommentArgs(this.businessId, this.postId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentArgs &&
          runtimeType == other.runtimeType &&
          businessId == other.businessId &&
          postId == other.postId;

  @override
  int get hashCode => businessId.hashCode ^ postId.hashCode;
}

final postCommentsProvider =
    StreamProvider.family<List<PostComment>, CommentArgs>((ref, args) {
  final repo = ref.watch(postRepositoryProvider);
  return repo.getCommentsStream(args.businessId, args.postId).map(
        (maps) => maps.map((m) => PostComment.fromMap(m['id'], m)).toList(),
      );
});

final postInteractionProvider = Provider((ref) {
  final repo = ref.watch(postRepositoryProvider);
  return PostInteractionNotifier(repo);
});

class PostInteractionNotifier {
  final PostRepository repo;
  PostInteractionNotifier(this.repo);

  Future<void> likePost(String businessId, String postId, String userId) async {
    await repo.likePost(businessId, postId, userId);
  }

  Future<void> addComment(
      String businessId, String postId, PostComment comment) async {
    await repo.addComment(businessId, postId, comment.toMap());
  }
}
