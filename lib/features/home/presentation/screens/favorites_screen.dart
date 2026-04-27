import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../providers/user_stats_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedAsync = ref.watch(userFollowedBusinessesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mis Favoritos',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: followedAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.error,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'No tienes favoritos aún',
                    style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Guarda los negocios que más te gustan para encontrarlos rápidamente aquí.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Counter header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${businesses.length} ${businesses.length == 1 ? 'negocio seguido' : 'negocios seguidos'}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Full list of followed businesses
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  itemCount: businesses.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final business = businesses[index];
                    return GestureDetector(
                      onTap: () => context.push(
                          '/business/${business.id}',
                          extra: business),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Imagen cuadrada
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              child: AppCachedImage(
                                imageUrl: business.imageUrl,
                                width: 100,
                                height: 100,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            business.name,
                                            style: AppTypography.titleMedium
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w800),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (business.isVerified)
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 4),
                                            child: Icon(
                                                Icons.verified_rounded,
                                                color: AppColors.primary,
                                                size: 16),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      business.category,
                                      style: AppTypography.bodySmall
                                          .copyWith(
                                              color:
                                                  AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded,
                                            color: Colors.amber, size: 14),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${business.rating}',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.bold),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '(${business.totalReviews})',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                  color: AppColors
                                                      .textSecondary,
                                                  fontSize: 11),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3),
                                          decoration: BoxDecoration(
                                            color: business.isOpen
                                                ? const Color(0xFF10B981)
                                                    .withValues(alpha: 0.12)
                                                : AppColors.textSecondary
                                                    .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Text(
                                            business.isOpen
                                                ? 'Abierto'
                                                : 'Cerrado',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: business.isOpen
                                                  ? const Color(0xFF10B981)
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.chevron_right_rounded,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
