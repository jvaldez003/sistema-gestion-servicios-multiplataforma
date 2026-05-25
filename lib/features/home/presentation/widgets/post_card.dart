import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

import '../../domain/models/post.dart';
import '../providers/post_providers.dart';
import '../providers/business_providers.dart';
import 'comment_modal.dart';
import '../../../../core/widgets/app_cached_image.dart';
import 'package:go_router/go_router.dart';

class PostCard extends ConsumerStatefulWidget {
  final BusinessPost post;
  final String currentUserId;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimController;
  late Animation<double> _likeAnimScale;

  late AnimationController _bigHeartAnimController;
  late Animation<double> _bigHeartScale;
  late Animation<double> _bigHeartOpacity;

  bool _isLikedLocal = false;

  @override
  void initState() {
    super.initState();
    _isLikedLocal = widget.post.likedByUsers.contains(widget.currentUserId);

    // Animation for the small heart icon
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeAnimScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
    ]).animate(_likeAnimController);

    // Animation for the big heart overlay
    _bigHeartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bigHeartScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20), // hold
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.5),
          weight: 20), // expand while fading
    ]).animate(_bigHeartAnimController);

    _bigHeartOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20),
    ]).animate(_bigHeartAnimController);
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.likedByUsers.contains(widget.currentUserId) !=
        oldWidget.post.likedByUsers.contains(oldWidget.currentUserId)) {
      _isLikedLocal = widget.post.likedByUsers.contains(widget.currentUserId);
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    _bigHeartAnimController.dispose();
    super.dispose();
  }

  int get _displayLikesCount {
    final originalLiked = widget.post.likedByUsers.contains(widget.currentUserId);
    int count = widget.post.likesCount;
    
    // If the local state differs from the backend, adjust the count optimistically
    if (_isLikedLocal && !originalLiked) {
      count++;
    } else if (!_isLikedLocal && originalLiked) {
      count--;
    }
    
    return count > 0 ? count : 0;
  }

  void _handleLike() {
    if (!_isLikedLocal) {
      _likeAnimController.forward(from: 0.0);
    }
    setState(() => _isLikedLocal = !_isLikedLocal);
    ref
        .read(postInteractionProvider)
        .likePost(widget.post.businessId, widget.post.id, widget.currentUserId);
  }

  void _handleDoubleTapLike() {
    _bigHeartAnimController.forward(from: 0.0);
    if (!_isLikedLocal) {
      _handleLike();
    }
  }

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              title: const Text('Eliminar publicación', style: TextStyle(color: Color(0xFFEF4444))),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: const Text('¿Eliminar publicación?'),
                    content: const Text('Esta acción es permanente.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancelar')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(d, true),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  try {
                    await ref.read(postRepositoryProvider).deletePost(widget.post.businessId, widget.post.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text('Publicación eliminada'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
                      );
                    }
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: AppColors.textSecondary),
              title: const Text('Reportar publicación'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Gracias por tu reporte. Lo revisaremos pronto.'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: AppColors.textSecondary),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(post: widget.post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Tighter margin between posts
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Avatar, Name, More button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      context.push('/business/${widget.post.businessId}'),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha:0.3),
                          width: 2), // Ring around avatar
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withValues(alpha:0.1),
                      child: widget.post.businessAvatar.isNotEmpty
                          ? AppCachedImage(
                              imageUrl: widget.post.businessAvatar,
                              borderRadius: BorderRadius.circular(16),
                            )
                          : const Icon(Icons.store,
                              color: AppColors.primary, size: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/business/${widget.post.businessId}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.businessName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('d MMM', 'es')
                              .format(widget.post.createdAt),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showPostMenu(context),
                ),
              ],
            ),
          ),

          // 2. Image with Double Tap Overlay
          if (widget.post.imageUrl != null)
            GestureDetector(
              onDoubleTap: _handleDoubleTapLike,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AppCachedImage(
                    imageUrl: widget.post.imageUrl!,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Animated Big Heart
                  AnimatedBuilder(
                    animation: _bigHeartAnimController,
                    builder: (context, child) {
                      if (_bigHeartAnimController.value == 0.0 ||
                          _bigHeartAnimController.value == 1.0) {
                        return const SizedBox.shrink();
                      }
                      return Transform.scale(
                        scale: _bigHeartScale.value,
                        child: Opacity(
                          opacity: _bigHeartOpacity.value,
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 100,
                            shadows: [
                              Shadow(
                                  color: Colors.black26,
                                  blurRadius: 20,
                                  offset: Offset(0, 10))
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          // 3. Interaction Bar (Like, Comment, Share)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                _AnimatedLikeButton(
                  isLiked: _isLikedLocal,
                  scaleAnimation: _likeAnimScale,
                  onTap: _handleLike,
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 26),
                  onPressed: () => _showComments(context),
                ),
                const Spacer(),
              ],
            ),
          ),

          // 4. Likes Count
          if (_displayLikesCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$_displayLikesCount ${_displayLikesCount == 1 ? 'me gusta' : 'me gusta'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

          // 5. Description (Business Name + Text)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                children: [
                  TextSpan(
                    text: '${widget.post.businessName} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.post.content,
                  ),
                ],
              ),
            ),
          ),

          // 6. View all comments link
          if (widget.post.commentsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: GestureDetector(
                onTap: () => _showComments(context),
                child: Text(
                  'Ver los ${widget.post.commentsCount} comentarios',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ),

          // 7. Booking Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: OutlinedButton(
              onPressed: widget.post.businessId.isEmpty
                  ? null
                  : () => context.push('/business/${widget.post.businessId}/booking'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha:0.5)),
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Reservar Cita',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Subtle divider between posts
          Container(height: 1, color: AppColors.border.withValues(alpha:0.5)),
        ],
      ),
    );
  }
}

class _AnimatedLikeButton extends StatelessWidget {
  final bool isLiked;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  const _AnimatedLikeButton({
    required this.isLiked,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: scaleAnimation.value,
              child: Icon(
                isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: isLiked ? AppColors.error : AppColors.textPrimary,
                size: 26,
              ),
            );
          },
        ),
      ),
    );
  }
}
