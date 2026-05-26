import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../providers/booking_providers.dart';
import '../widgets/appointments_tab.dart';
import '../widgets/category_selector.dart';
import '../widgets/promotional_banner.dart';
import '../providers/post_providers.dart';
import '../providers/business_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/profile_tab.dart';
import '../widgets/post_card.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../domain/models/business.dart';
import '../widgets/business_search_delegate.dart';
import '../providers/notification_providers.dart';
import 'notifications_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(appointmentNotificationSyncProvider);
    final selectedIndex = ref.watch(homeTabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          ExplorarTab(),
          AppointmentsTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(homeTabIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Mis Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class ExplorarTab extends ConsumerWidget {
  const ExplorarTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesStreamProvider);
    final postsAsync = ref.watch(globalFeedProvider);
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.id ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 50,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            children: [
                              const TextSpan(text: 'Hola, '),
                              TextSpan(
                                text: (authState.value?.name ?? 'Invitado')
                                    .split(' ')
                                    .first,
                                style:
                                    const TextStyle(color: AppColors.primary),
                              ),
                              const TextSpan(text: ' 👋'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¿Qué servicio buscas hoy?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _HeaderIcon(
                    icon: Icons.search_rounded,
                    isDark: isDark,
                    onTap: () {
                      final businesses = businessesAsync.valueOrNull ?? [];
                      showSearch(
                        context: context,
                        delegate:
                            BusinessSearchDelegate(businesses: businesses),
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _HeaderIcon(
                    icon: Icons.notifications_none_rounded,
                    isDark: isDark,
                    showBadge: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Categories ────────────────────────────────────────────────
          const SliverToBoxAdapter(child: CategorySelector()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // ── Banner ────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: PromotionalBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // ── Featured businesses ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Negocios Destacados',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          final businesses = businessesAsync.valueOrNull ?? [];
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => DraggableScrollableSheet(
                              initialChildSize: 0.7,
                              maxChildSize: 0.95,
                              minChildSize: 0.4,
                              expand: false,
                              builder: (_, scrollCtrl) => Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.borderDark
                                          : AppColors.border,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      'Todos los negocios',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: ListView.separated(
                                      controller: scrollCtrl,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      itemCount: businesses.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 1),
                                      itemBuilder: (ctx, i) {
                                        final b = businesses[i];
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8),
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                b.avatarUrl.isNotEmpty
                                                    ? NetworkImage(b.avatarUrl)
                                                    : null,
                                            child: b.avatarUrl.isEmpty
                                                ? const Icon(Icons.store)
                                                : null,
                                          ),
                                          title: Text(b.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(b.category),
                                          trailing: Text(
                                            '⭐ ${b.rating.toStringAsFixed(1)}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            context.push('/business/${b.id}',
                                                extra: b);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Rating filter chips
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Consumer(
                    builder: (ctx, ref, _) {
                      final minRating = ref.watch(ratingFilterProvider);
                      return Row(
                        children: [
                          Icon(
                            Icons.filter_list_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rating mín:',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ...([0.0, 3.0, 4.0, 4.5]).map((r) {
                            final isSelected = minRating == r;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(ratingFilterProvider.notifier)
                                    .state = r,
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.surfaceVariantDark
                                            : AppColors.surface),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.borderDark
                                              : AppColors.border),
                                    ),
                                  ),
                                  child: Text(
                                    r == 0 ? 'Todos' : '${r}+',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.textOnDark
                                              : AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                Consumer(
                  builder: (ctx, ref, _) {
                    final filtered = ref.watch(filteredBusinessesProvider);
                    return businessesAsync.when(
                      data: (_) => filtered.isEmpty
                          ? SizedBox(
                              height: 120,
                              child: Center(
                                child: Text(
                                  'No hay negocios para estos filtros',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 280,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.lg,
                                  right: AppSpacing.lg,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) =>
                                    _PremiumBusinessCard(
                                        business: filtered[index]),
                              ),
                            ),
                      loading: () => SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(left: AppSpacing.lg),
                          itemCount: 3,
                          itemBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SizedBox(
                              width: 240,
                              child: BusinessCardShimmer(),
                            ),
                          ),
                        ),
                      ),
                      error: (err, _) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

          // ── Social feed header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explora Tendencias',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Descubre los mejores trabajos de hoy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),

          // ── Social feed items ─────────────────────────────────────────
          postsAsync.when(
            data: (posts) {
              if (posts.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No hay publicaciones recientes')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PostCard(
                    post: posts[index],
                    currentUserId: currentUserId,
                  ),
                  childCount: posts.length,
                ),
              );
            },
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const PostShimmer(),
                childCount: 3,
              ),
            ),
            error: (err, _) {
              if (err.toString().contains('failed-precondition')) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Colors.amber, size: 32),
                          const SizedBox(height: 12),
                          Text(
                            'Configurando el Feed Social',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Firebase está preparando el índice necesario. '
                            'Por favor, haz clic en el enlace del error anterior '
                            'en tu consola para activarlo. Esto solo toma un par de minutos.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')));
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

// ── Header icon button ────────────────────────────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool showBadge;
  final VoidCallback? onTap;

  const _HeaderIcon({
    required this.icon,
    required this.isDark,
    this.showBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              size: 22,
            ),
            if (showBadge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Premium business card ─────────────────────────────────────────────────────

class _PremiumBusinessCard extends StatelessWidget {
  final Business business;

  const _PremiumBusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/business/${business.id}', extra: business),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Background image / gradient
              Positioned.fill(
                child: business.imageUrl.isNotEmpty ||
                        business.avatarUrl.isNotEmpty ||
                        business.galleryImages.isNotEmpty
                    ? AppCachedImage(
                        imageUrl: business.imageUrl.isNotEmpty
                            ? business.imageUrl
                            : (business.avatarUrl.isNotEmpty
                                ? business.avatarUrl
                                : business.galleryImages.first),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.8),
                              AppColors.accentPurple,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.storefront_outlined,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Glassmorphism info panel
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  business.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: Color(0xFFFFD700), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      business.rating.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('•',
                                        style:
                                            TextStyle(color: Colors.white54)),
                                    const SizedBox(width: 8),
                                    Text(
                                      business.category,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => context.push(
                              '/business/${business.id}/booking',
                              extra: business,
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 10)
                                ],
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Distance badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${business.distance} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
