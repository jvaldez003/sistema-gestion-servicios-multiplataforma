import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../admin/presentation/providers/admin_providers.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../providers/user_stats_providers.dart';
import '../providers/booking_providers.dart';
import '../widgets/business_small_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../screens/personal_data_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/security_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/settings_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final user = userProfileAsync.value ?? authState.user;
    final businessAsync = ref.watch(adminBusinessProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with Purple Gradient
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(context),
                Positioned(
                  top: 110,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: _buildProfileCard(context, user),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 160), // Adjusted space for overlapping card
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: _buildStatsRow(context, ref),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // Favoritos Section Header
          SliverToBoxAdapter(
            child: _buildSectionHeader(
                context, 'Negocios Favoritos', 'Ver todos', Icons.favorite,
                color: AppColors.error,
                onSubtitleTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                )),
          ),

          // Favorites Horizontal List
          SliverToBoxAdapter(
            child: _buildFavoritesList(context, ref),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // Cuenta Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'CUENTA', '', Icons.person,
                isCategory: true),
          ),
          SliverToBoxAdapter(
            child: _buildMenuContainer(context, [
              _buildMenuItem(
                context,
                icon: Icons.person_outline,
                title: 'Datos personales',
                subtitle: '${user?.name ?? 'Nombre no configurado'} | ${user?.phoneNumber ?? 'Sin teléfono'}',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalDataScreen(),
                  ),
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.notifications_none_outlined,
                title: 'Notificaciones',
                subtitle: 'Activadas',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.lock_outline,
                title: 'Seguridad',
                subtitle: 'Contraseña y privacidad',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityScreen(),
                  ),
                ),
                isLast: true,
              ),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Business Section (Conditional)
          businessAsync.when(
            data: (business) {
              final isProfessional = ref.watch(isProfessionalProvider);
              if (business == null && !isProfessional)
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              
              return SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSectionHeader(context, 'GESTIÓN PROFESIONAL', '', Icons.work_outline,
                        isCategory: true),
                    _buildMenuContainer(context, [
                      if (business != null)
                        _buildMenuItem(
                          context,
                          icon: Icons.dashboard_outlined,
                          title: 'Panel de Administrador',
                          subtitle: 'Gestionar ${business.name}',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminDashboardScreen(),
                            ),
                          ),
                          isLast: !isProfessional,
                        ),
                      if (isProfessional)
                        _buildMenuItem(
                          context,
                          icon: Icons.calendar_month_outlined,
                          title: 'Mi Horario de Trabajo',
                          subtitle: 'Configura tus horas disponibles',
                          onTap: () => context.push('/schedule'),
                          isLast: true,
                        ),
                    ]),
                  ],
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Actividad Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'ACTIVIDAD', '', Icons.insights_rounded,
                isCategory: true),
          ),
          SliverToBoxAdapter(
            child: _buildMenuContainer(context, [
              _buildMenuItem(
                context,
                icon: Icons.favorite_border_rounded,
                title: 'Favoritos',
                subtitle: 'Negocios que te encantan',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.history_rounded,
                title: 'Mis pedidos',
                subtitle: 'Historial de compras',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdersScreen(),
                  ),
                ),
                isLast: true,
              ),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Promo Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _buildPromoCard(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // Footer info
          SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flash_on,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'FlowServ v1.0.0',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: OutlinedButton(
                      onPressed: () =>
                          ref.read(authNotifierProvider.notifier).signOut(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: Color(0xFFFFECEC)),
                        backgroundColor: const Color(0xFFFFF9F9),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Cerrar sesión',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF6366F1), // Indigo blend
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Perfil',
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              _buildHeaderIcon(context, Icons.notifications_none_rounded,
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      ),
                  showBadge: true),
              const SizedBox(width: AppSpacing.md),
              _buildHeaderIcon(context, Icons.settings_outlined,
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon,
      {required VoidCallback onTap, bool showBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            if (showBadge)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Green for notifications
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                      ? AppCachedImage(
                          imageUrl: user.photoUrl!,
                          borderRadius: BorderRadius.circular(28),
                        )
                      : Text(
                          (user?.name != null && user!.name!.isNotEmpty)
                              ? user.name![0].toUpperCase()
                              : '?',
                          style: AppTypography.h1.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: AppColors.primary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Configurar Perfil',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'correo@ejemplo.com',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Miembro Silver',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(userAppointmentsProvider);
    final points = ref.watch(userPointsProvider);
    final followedAsync = ref.watch(userFollowedBusinessesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              appointmentsAsync.maybeWhen(
                data: (appointments) => '${appointments.where((a) => a.status != 'cancelled').length}',
                orElse: () => '...',
              ),
              'Citas',
              Icons.calendar_month_rounded,
              const Color(0xFFF97316),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              '$points',
              'Puntos',
              Icons.stars_rounded,
              const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              followedAsync.maybeWhen(
                data: (followed) => '${followed.length}',
                orElse: () => '...',
              ),
              'Favoritos',
              Icons.favorite_rounded,
              const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String subtitle, IconData icon,
      {Color? color, bool isCategory = false, VoidCallback? onSubtitleTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
      child: Row(
        children: [
          if (isCategory)
            Icon(icon, color: AppColors.textSecondary, size: 18)
          else
            Icon(icon, color: color ?? AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: isCategory
                ? AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  )
                : AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
          ),
          const Spacer(),
          if (subtitle.isNotEmpty)
            GestureDetector(
              onTap: onSubtitleTap,
              child: Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: onSubtitleTap != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: onSubtitleTap != null ? FontWeight.bold : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, WidgetRef ref) {
    final followedAsync = ref.watch(userFollowedBusinessesProvider);

    return followedAsync.when(
      data: (businesses) {
        if (businesses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  Icon(Icons.favorite_border_rounded, color: AppColors.textSecondary.withOpacity(0.3), size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Aquí verás tus negocios favoritos',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Solo mostramos máximo 3 en el cuadro de favoritos del perfil
        final preview = businesses.take(3).toList();

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: preview.length,
            itemBuilder: (context, index) {
              final business = preview[index];
              return BusinessSmallCard(business: business);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMenuContainer(BuildContext context, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      VoidCallback? onTap,
      bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          title: Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.bodySmall,
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(height: 1, indent: 70, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFF9D00)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.storefront_outlined,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Tienes un negocio?',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Regístralo gratis en FlowServ',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ],
      ),
    );
  }
}
