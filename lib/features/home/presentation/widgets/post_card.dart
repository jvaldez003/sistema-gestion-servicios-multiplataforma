import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/post.dart';
import '../providers/post_providers.dart';
import 'comment_modal.dart';
import '../../../../core/widgets/app_cached_image.dart';
import 'package:go_router/go_router.dart';

class PostCard extends ConsumerWidget {
  final BusinessPost post;
  final String currentUserId;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = post.likedByUsers.contains(currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/business/${post.businessId}'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: post.businessAvatar.isNotEmpty
                        ? AppCachedImage(
                            imageUrl: post.businessAvatar,
                            borderRadius: BorderRadius.circular(20),
                          )
                        : const Icon(Icons.store, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => context.push('/business/${post.businessId}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.businessName,
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Publicado hace ${DateFormat('d MMM', 'es').format(post.createdAt)}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildActionButton(Icons.more_horiz_rounded, () {}),
              ],
            ),
          ),

          // Content Image
          if (post.imageUrl != null)
            GestureDetector(
              onDoubleTap: () => _handleLike(ref),
              child: AppCachedImage(
                imageUrl: post.imageUrl!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title != null)
                  Text(
                    post.title!,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 4),
                Text(
                  post.content,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          // Interaction Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _buildInteractionIcon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  post.likesCount.toString(),
                  isLiked ? AppColors.error : AppColors.textPrimary,
                  () => _handleLike(ref),
                ),
                _buildInteractionIcon(
                  Icons.chat_bubble_outline_rounded,
                  post.commentsCount.toString(),
                  AppColors.textPrimary,
                  () => _showComments(context),
                ),
                const Spacer(),
                _buildInteractionIcon(Icons.share_outlined, '', AppColors.textPrimary, () {}),
              ],
            ),
          ),

          // Business Action Button (Reservar)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => context.push('/business/${post.businessId}/booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.08),
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Reservar Cita en ${post.businessName.split(' ')[0]}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildInteractionIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            if (label != '0' && label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleLike(WidgetRef ref) {
    ref.read(postInteractionProvider).likePost(post.businessId, post.id, currentUserId);
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(post: post),
    );
  }
}
