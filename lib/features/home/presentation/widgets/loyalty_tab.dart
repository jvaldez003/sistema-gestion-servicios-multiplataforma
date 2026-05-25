import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

import '../providers/user_stats_providers.dart';

class LoyaltyTab extends ConsumerWidget {
  const LoyaltyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(userPointsProvider);
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Puntos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acumula puntos en tus visitas y canjéalos por premios.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  _buildPointsCard(context, points),
                  const SizedBox(height: 32),
                  Text(
                    'Historial de Puntos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildHistoryList(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            const Color(0xFFC084FC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            '$points',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
          ),
          Text(
            'Puntos Acumulados',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Mostrar QR para sumar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(pointsHistoryProvider);
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                'Aún no tienes historial de puntos.\nCompleta una cita para ganar puntos.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (ctx, index) => Divider(height: 1, color: Theme.of(ctx).dividerColor),
          itemBuilder: (ctx, index) {
            final item = history[index];
            final isEarned = (item['type'] ?? 'earned') == 'earned';
            final pts = item['points'] ?? 0;
            DateTime? date;
            try { date = (item['createdAt'] as dynamic).toDate(); } catch (_) {}
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isEarned ? const Color(0xFFE0F2FE) : const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEarned ? Icons.add_rounded : Icons.remove_rounded,
                      color: isEarned ? const Color(0xFF0284C7) : const Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['reason'] ?? (isEarned ? 'Puntos ganados' : 'Puntos canjeados'),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (date != null)
                          Text(
                            DateFormat('d MMM yyyy', 'es').format(date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${isEarned ? '+' : '-'}$pts pts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isEarned ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
