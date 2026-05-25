import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/business.dart';

class BusinessCard extends StatelessWidget {
  final Business business;

  const BusinessCard({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/business/${business.id}', extra: business),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(28),
          border: isDark ? Border.all(color: AppColors.borderDark) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: business.avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(business.avatarUrl)
                        : null,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: business.avatarUrl.isEmpty
                        ? Text(
                            business.name.substring(0, 1).toUpperCase(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                business.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (business.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: AppColors.primary, size: 16),
                            ],
                            if (business.isTop) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.trending_up, color: Color(0xFFF97316), size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      'TOP',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFFF97316),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${business.category}  •  ${business.distance} km',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Abierto',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF065F46),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (business.galleryImages.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl: business.galleryImages.isNotEmpty
                          ? business.galleryImages.first
                          : business.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined, size: 40, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Desde',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '\$${business.startingPrice.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${business.rating}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${business.totalReviews})',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (business.galleryImages.length > 1)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          business.galleryImages.length.clamp(0, 5),
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: index == 0 ? 16 : 6,
                            height: 4,
                            decoration: BoxDecoration(
                              color: index == 0 ? Colors.white : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (business.galleryImages.length > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.image_outlined, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '1/${business.galleryImages.length}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✂️ ${business.description}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: business.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  _buildMetric(context, Icons.favorite_border,
                      '${business.likes >= 1000 ? '${(business.likes / 1000).toStringAsFixed(1)}k' : business.likes}'),
                  const SizedBox(width: 16),
                  _buildMetric(context, Icons.chat_bubble_outline, '${business.comments}'),
                  const SizedBox(width: 16),
                  _buildMetric(context, Icons.share_outlined, ''),
                  const Spacer(),
                  _buildMetric(context, Icons.bookmark_border_outlined, ''),
                  const SizedBox(width: 16),
                  _buildMetric(context, Icons.group_outlined, '${business.professionalCount} prof.'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: ElevatedButton(
                onPressed: () => context.push('/business/${business.id}/booking', extra: business),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Reservar cita',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13)),
        ],
      ],
    );
  }
}
