import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/booking_providers.dart';
import '../widgets/appointments_tab.dart';
import '../widgets/category_selector.dart';
import '../widgets/promotional_banner.dart';
import '../providers/post_providers.dart';
import '../providers/business_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/profile_tab.dart';
import '../widgets/loyalty_tab.dart';
import '../widgets/post_card.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../domain/models/business.dart';
import '../widgets/business_search_delegate.dart';

import '../providers/notification_providers.dart';

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
      backgroundColor: const Color(0xFFF9FAFB),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          const ExplorarTab(),
          const AppointmentsTab(),
          const LoyaltyTab(),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(homeTabIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        unselectedLabelStyle: AppTypography.bodySmall,
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
            icon: Icon(Icons.card_membership_outlined),
            activeIcon: Icon(Icons.card_membership),
            label: 'Puntos',
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

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header FlowServ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
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
                            style: AppTypography.h2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                            children: [
                              const TextSpan(text: 'Hola, '),
                              TextSpan(
                                text: (authState.value?.name ?? 'Invitado').split(' ').first,
                                style: const TextStyle(color: AppColors.primary),
                              ),
                              const TextSpan(text: ' 👋'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¿Qué servicio buscas hoy?',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _buildHeaderIcon(
                    Icons.search_rounded,
                    onTap: () {
                      final businesses = businessesAsync.valueOrNull ?? [];
                      showSearch(
                        context: context,
                        delegate: BusinessSearchDelegate(businesses: businesses),
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildHeaderIcon(Icons.notifications_none_rounded, showBadge: true),
                ],
              ),
            ),
          ),

          // Categories Horizontal
          const SliverToBoxAdapter(child: CategorySelector()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Banner
          const SliverToBoxAdapter(child: PromotionalBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // Top Businesses Section (Horizontal)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Negocios Destacados',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                businessesAsync.when(
                  data: (businesses) => SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg),
                      itemCount: businesses.length,
                      itemBuilder: (context, index) {
                        final b = businesses[index];
                        return _PremiumBusinessCard(business: b);
                      },
                    ),
                  ),
                  loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                  error: (err, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

          // Social Feed Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explora Tendencias',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Descubre los mejores trabajos de hoy',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),

          // Social Feed Items
          postsAsync.when(
            data: (posts) {
              if (posts.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('No hay publicaciones recientes'),
                  ),
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
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            ),
            error: (err, _) {
              if (err.toString().contains('failed-precondition')) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 32),
                          const SizedBox(height: 12),
                          Text(
                            'Configurando el Feed Social',
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Firebase está preparando el índice necesario. Por favor, haz clic en el enlace del error anterior en tu consola para activarlo. Esto solo toma un par de minutos.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverToBoxAdapter(child: Center(child: Text('Error: $err')));
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {bool showBadge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 22),
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
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    ));
  }
}

class _PremiumBusinessCard extends StatelessWidget {
  final Business business;

  const _PremiumBusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/business/${business.id}', extra: business),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // 1. Full Background
              Positioned.fill(
                child: business.imageUrl.isNotEmpty || business.avatarUrl.isNotEmpty || business.galleryImages.isNotEmpty
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
                              AppColors.primary.withOpacity(0.8),
                              const Color(0xFFC084FC),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.storefront_outlined,
                            size: 80,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
              ),

              // 2. Gradient Overlay for readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Glassmorphism Info Panel
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
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      business.rating.toString(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('•', style: TextStyle(color: Colors.white54)),
                                    const SizedBox(width: 8),
                                    Text(
                                      business.category,
                                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Minimalist Circle Action Button
                          GestureDetector(
                            onTap: () => context.push('/business/${business.id}/booking', extra: business),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                              ),
                              child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // 4. Distance Badge (Floating top-right)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${business.distance} km',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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


