import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // Header with Purple Background
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(context),
                Positioned(
                  top: 100,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: _buildProfileCard(context, user),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 150), // Space for overlapping card
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: _buildStatsRow(context),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // Favoritos Section Header
          _buildSectionHeader(
              context, 'Favoritos', '3 negocios', Icons.favorite,
              color: AppColors.error),

          // Favorites Horizontal List
          SliverToBoxAdapter(
            child: _buildFavoritesList(context),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // Cuenta Section
          _buildSectionHeader(context, 'CUENTA', '', Icons.person,
              isCategory: true),
          SliverToBoxAdapter(
            child: _buildMenuContainer(context, [
              _buildMenuItem(
                context,
                icon: Icons.person_outline,
                title: 'Datos personales',
                subtitle: user?.name ?? 'María González',
              ),
              _buildMenuItem(
                context,
                icon: Icons.location_on_outlined,
                title: 'Direcciones guardadas',
                subtitle: '2 direcciones',
              ),
              _buildMenuItem(
                context,
                icon: Icons.notifications_none_outlined,
                title: 'Notificaciones',
                subtitle: 'Activadas',
              ),
              _buildMenuItem(
                context,
                icon: Icons.lock_outline,
                title: 'Seguridad',
                subtitle: 'Contraseña y privacidad',
                isLast: true,
              ),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Actividad Section
          _buildSectionHeader(context, 'ACTIVIDAD', '', Icons.work,
              isCategory: true),
          SliverToBoxAdapter(
            child: _buildMenuContainer(context, [
              _buildMenuItem(
                context,
                icon: Icons.favorite_border,
                title: 'Negocios favoritos',
                subtitle: '3 guardados',
              ),
              _buildMenuItem(
                context,
                icon: Icons.business_center_outlined,
                title: 'Mis postulaciones',
                subtitle: '1 enviadas',
              ),
              _buildMenuItem(
                context,
                icon: Icons.shopping_cart_outlined,
                title: 'Mis pedidos',
                subtitle: 'Ver historial',
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
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Perfil',
                style: AppTypography.h2.copyWith(color: Colors.white),
              ),
              const Spacer(),
              _buildHeaderIcon(Icons.notifications_none_outlined,
                  showBadge: true),
              const SizedBox(width: AppSpacing.md),
              _buildHeaderIcon(Icons.edit_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {bool showBadge = false}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          if (showBadge)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    user?.name?.substring(0, 1).toUpperCase() ?? 'M',
                    style: AppTypography.h1.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '+ Foto',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'María González',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'maria@email.com',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Bogotá',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('12', 'Citas', Icons.calendar_month_outlined,
              const Color(0xFFF97316)),
          _buildStatItem('320', 'Puntos', Icons.star_outline, Colors.amber),
          _buildStatItem(
              '3', 'Favoritos', Icons.favorite_border, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String subtitle, IconData icon,
      {Color? color, bool isCategory = false}) {
    return SliverToBoxAdapter(
      child: Padding(
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
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Text(
        'Aún no tienes negocios favoritos',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
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
          onTap: () {},
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
