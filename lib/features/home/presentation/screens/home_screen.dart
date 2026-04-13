import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/business_card.dart';
import '../widgets/appointments_tab.dart';
import '../widgets/category_selector.dart';
import '../widgets/promotional_banner.dart';
import '../providers/business_providers.dart';
import '../widgets/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const ExplorarTab(),
          const AppointmentsTab(),
          const Center(child: Text('Próximamente: Sistema de Puntos')),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on,
                              color: AppColors.primary, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'FlowServ',
                            style: AppTypography.h2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Ubicación no detectada',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildHeaderIcon(Icons.search),
                  const SizedBox(width: AppSpacing.md),
                  _buildHeaderIcon(Icons.notifications_none_outlined,
                      showBadge: true),
                ],
              ),
            ),
          ),

          // Categories
          const SliverToBoxAdapter(
            child: CategorySelector(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl),
          ),

          // Promotional Banner
          const SliverToBoxAdapter(
            child: PromotionalBanner(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl),
          ),

          // Trends
          const SliverToBoxAdapter(child: SizedBox.shrink()),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl),
          ),

          // Popular Section
          businessesAsync.when(
            data: (businesses) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Populares cerca de ti',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${businesses.length} resultados',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon:
                              const Icon(Icons.location_on_outlined, size: 14),
                          label: const Text('Ver mapa'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $err')),
            ),
          ),

          // Business List
          businessesAsync.when(
            data: (businesses) {
              if (businesses.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: Text('No hay negocios registrados aún'),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        BusinessCard(business: businesses[index]),
                    childCount: businesses.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (err, stack) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {bool showBadge = false}) {
    return Container(
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
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: AppTypography.h2.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
