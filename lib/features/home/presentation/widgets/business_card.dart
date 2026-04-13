import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/business.dart';
import '../screens/business_profile_screen.dart';
import '../screens/booking_screen.dart';

class BusinessCard extends StatelessWidget {
  final Business business;

  const BusinessCard({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/business/${business.id}', extra: business),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Badges
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: business.avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(business.avatarUrl)
                        : null,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: business.avatarUrl.isEmpty
                        ? Text(
                            business.name.substring(0, 1).toUpperCase(),
                            style: AppTypography.titleMedium.copyWith(
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
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (business.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified,
                                  color: AppColors.primary, size: 16),
                            ],
                            if (business.isTop) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.trending_up,
                                        color: Color(0xFFF97316), size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      'TOP',
                                      style: AppTypography.bodySmall.copyWith(
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
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          style: AppTypography.bodySmall.copyWith(
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

            // Main Image with Overlays (only if gallery images exist)
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
                          child: Icon(Icons.image_not_supported_outlined,
                              size: 40, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Price and Rating
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
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '\$${business.startingPrice.toStringAsFixed(0)}',
                                style: AppTypography.h3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${business.rating}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${business.totalReviews})',
                                style: AppTypography.bodySmall.copyWith(
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
                  // Carousel Indicator
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
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  width: index == 0 ? 16 : 6,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )),
                      ),
                    ),
                  // Image Counter Tag
                  if (business.galleryImages.length > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.image_outlined,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '1/${business.galleryImages.length}',
                              style: AppTypography.bodySmall.copyWith(
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

            // Description and Tags
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✂️ ${business.description}',
                    style: AppTypography.bodyMedium.copyWith(
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tag,
                                style: AppTypography.bodySmall.copyWith(
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

            // Footer Metrics
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  _buildMetric(Icons.favorite_border,
                      '${business.likes >= 1000 ? '${(business.likes / 1000).toStringAsFixed(1)}k' : business.likes}'),
                  const SizedBox(width: 16),
                  _buildMetric(
                      Icons.chat_bubble_outline, '${business.comments}'),
                  const SizedBox(width: 16),
                  _buildMetric(Icons.share_outlined, ''),
                  const Spacer(),
                  _buildMetric(Icons.bookmark_border_outlined, ''),
                  const SizedBox(width: 16),
                  _buildMetric(Icons.group_outlined,
                      '${business.professionalCount} prof.'),
                ],
              ),
            ),

            // Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: ElevatedButton(
                onPressed: () => context.push('/business/${business.id}/booking', extra: business),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Reservar cita',
                      style: AppTypography.titleMedium
                          .copyWith(color: Colors.white),
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

  Widget _buildMetric(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(fontSize: 13),
          ),
        ],
      ],
    );
  }
}
