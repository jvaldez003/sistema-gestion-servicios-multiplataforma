import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/post.dart';
import '../providers/post_providers.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final BusinessPost post;

  const CommentBottomSheet({super.key, required this.post});

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    if (_controller.text.trim().isEmpty) return;

    final authUser = ref.read(authStateProvider).value;
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes iniciar sesión para comentar')));
      return;
    }

    final profile = ref.read(userProfileProvider).value;

    setState(() => _isSending = true);

    try {
      final comment = PostComment(
        id: '', // Will be set by Firestore
        userId: authUser.id,
        userName: profile?.name ?? authUser.email.split('@')[0] ?? 'Usuario',
        userAvatar: profile?.photoUrl ?? '',
        text: _controller.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(postInteractionProvider).addComment(
            widget.post.businessId,
            widget.post.id,
            comment,
          );

      _controller.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(postCommentsProvider(CommentArgs(widget.post.businessId, widget.post.id)));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  'Comentarios',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.post.commentsCount.toString(),
                  style: AppTypography.titleLarge.copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                _buildActionButton(Icons.close_rounded, () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, 
                             size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Aún no hay comentarios',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          'Sé el primero en comentar',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: comment.userAvatar.isNotEmpty
                                ? NetworkImage(comment.userAvatar)
                                : null,
                            child: comment.userAvatar.isEmpty ? const Icon(Icons.person, size: 18) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment.userName,
                                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('d MMM', 'es').format(comment.createdAt),
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.text,
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
          const Divider(height: 1),
          // Input Area
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).viewInsets.bottom),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Añade un comentario...',
                        border: InputBorder.none,
                      ),
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _isSending ? null : _sendComment,
                  icon: _isSending 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
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
        child: Icon(icon, color: AppColors.textPrimary, size: 24),
      ),
    );
  }
}
