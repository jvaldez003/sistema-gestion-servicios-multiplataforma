import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gestion_servicios_multiplataforma/core/widgets/app_cached_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/service.dart';
import '../../domain/models/business.dart';
import '../providers/business_details_providers.dart';
import '../providers/business_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/models/post.dart';
import '../widgets/post_card.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  final Business? business;
  final String? businessId;

  const BusinessProfileScreen({
    super.key,
    this.business,
    this.businessId,
  });

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessId = widget.business?.id ?? widget.businessId!;
    final businessDetailsAsync = ref.watch(businessStreamProvider(businessId));

    return businessDetailsAsync.when(
      data: (business) {
        if (business == null) {
          return const Scaffold(
            body: Center(child: Text('Negocio no encontrado')),
          );
        }

        final postsAsync = ref.watch(businessPostsProvider(businessId));
        final servicesAsync = ref.watch(businessServicesProvider(businessId));
        final productsAsync = ref.watch(businessProductsProvider(businessId));
        final teamAsync = ref.watch(businessTeamProvider(businessId));
        final isFollowingAsync =
            ref.watch(isFollowingBusinessProvider(businessId));
        final authState = ref.watch(authStateProvider);
        final membershipStatus = ref.watch(userMembershipStatusProvider(businessId));

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              // Header: Cover Image & Back Button & Actions
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined,
                          color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildCoverImage(business),
                ),
              ),

              // Profile Header Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(business, isFollowingAsync, authState, businessId, membershipStatus),
                      const SizedBox(height: AppSpacing.md),
                      _buildDescription(business),
                      const SizedBox(height: AppSpacing.lg),
                      _buildStatsRow(business, postsAsync, businessDetailsAsync),
                      const SizedBox(height: AppSpacing.lg),
                      _buildInfoChips(business),
                    ],
                  ),
                ),
              ),

              // Sticky Tabs View
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    labelStyle: AppTypography.bodySmall
                        .copyWith(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_view_rounded, size: 20), text: 'Posts'),
                      Tab(icon: Icon(Icons.layers_outlined, size: 20), text: 'Servicios'),
                      Tab(icon: Icon(Icons.shopping_bag_outlined, size: 20), text: 'Tienda'),
                      Tab(icon: Icon(Icons.info_outline, size: 20), text: 'Info'),
                    ],
                  ),
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsTab(postsAsync, business, authState.value?.id ?? ''),
                    _buildServicesTab(servicesAsync),
                    _buildProductsTab(productsAsync),
                    _buildInfoTab(teamAsync, business),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBookingBar(business),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeaderRow(Business business, AsyncValue<bool> isFollowingAsync, AsyncValue<AppUser?> authState, String businessId, MembershipStatus membershipStatus) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: business.avatarUrl.isNotEmpty
                    ? AppCachedImage(
                        imageUrl: business.avatarUrl,
                        borderRadius: BorderRadius.circular(40),
                      )
                    : Text(
                        business.name.substring(0, 1).toUpperCase(),
                        style: AppTypography.h1.copyWith(color: AppColors.primary),
                      ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                business.name,
                style: AppTypography.h2.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '@${business.name.toLowerCase().replaceAll(' ', '')} • ${business.category}',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFollowBtnInternal(isFollowingAsync, authState, businessId),
                  _buildWorkRequestBtnInternal(business, authState, membershipStatus),
                  _buildReservarBtnInternal(business),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowBtnInternal(AsyncValue<bool> isFollowingAsync, AsyncValue<AppUser?> authState, String businessId) {
    return isFollowingAsync.when(
      data: (isFollowing) => OutlinedButton(
        onPressed: () async {
          final user = authState.value;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes iniciar sesión para seguir negocios')));
            return;
          }
          await ref.read(businessRepositoryProvider).toggleFollowBusiness(businessId, user.id);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: const Size(0, 36),
        ),
        child: Text(isFollowing ? 'Siguiendo' : 'Seguir', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
      loading: () => const SizedBox(width: 80, height: 36, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildWorkRequestBtnInternal(Business business, AsyncValue<AppUser?> authState, MembershipStatus status) {
    if (status == MembershipStatus.accepted) return const SizedBox.shrink();

    final isPending = status == MembershipStatus.pending;

    return OutlinedButton(
      onPressed: isPending ? null : () async {
        final user = authState.value;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes iniciar sesión para solicitar trabajo')));
          return;
        }
        
        await ref.read(businessRepositoryProvider).sendWorkRequest(
          business.id,
          user.id,
          user.name ?? 'Usuario',
          user.photoUrl ?? '',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada con éxito')));
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: isPending ? Colors.grey : AppColors.primary,
        side: BorderSide(color: isPending ? Colors.grey.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, 36),
      ),
      child: Text(
        isPending ? 'Petición enviada' : 'Solicitar trabajo',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildReservarBtnInternal(Business business) {
    return ElevatedButton(
      onPressed: () => context.push('/business/${business.id}/booking', extra: business),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, 36),
        elevation: 0,
      ),
      child: const Text('Reservar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildDescription(Business business) {
    return Text(
      '✂️ ${business.description}',
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildStatsRow(Business business, AsyncValue<List<Map<String, dynamic>>> postsAsync, AsyncValue<Business?> detailsAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            postsAsync.when(
                data: (posts) => _buildStat('${posts.length}', 'Posts'),
                loading: () => _buildStat('...', 'Posts'),
                error: (_, __) => _buildStat('0', 'Posts')),
            _buildDivider(),
            detailsAsync.when(
                data: (b) => _buildStat('${b?.followerCount ?? 0}', 'Seguidores'),
                loading: () => _buildStat('...', 'Seguidores'),
                error: (_, __) => _buildStat('0', 'Seguidores')),
            _buildDivider(),
            _buildStat('${business.rating}', 'Rating', isStar: true),
            _buildDivider(),
            _buildStat('${business.professionalCount}', 'Equipo'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChips(Business business) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildInfoChip(Icons.location_on_outlined, '${business.distance} km'),
          _buildInfoChip(Icons.phone_outlined, '+57 300 123 4567'),
          _buildInfoChip(Icons.access_time, 'Hoy 9AM-7PM', color: const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildBottomBookingBar(Business business) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => context.push('/business/${business.id}/booking', extra: business),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Agendar Cita Ahora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPostsTab(AsyncValue<List<Map<String, dynamic>>> postsAsync, Business business, String currentUserId) {
    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('Aún no hay publicaciones.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final postData = posts[index];
            final post = BusinessPost.fromMap(
              postData['id'], 
              postData,
              businessName: business.name,
              businessAvatar: business.avatarUrl,
            );
            return PostCard(
              post: post,
              currentUserId: currentUserId,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildServicesTab(AsyncValue<List<Service>> servicesAsync) {
    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return const Center(child: Text('Aún no hay servicios.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ListTile(
              title: Text(service.name),
              subtitle: Text(service.duration),
              trailing: Text(
                '\$${service.price}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildProductsTab(AsyncValue<List<Map<String, dynamic>>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('Aún no hay productos en la tienda.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCachedImage(
                      imageUrl: product['imageUrl'],
                      width: double.infinity,
                      errorIcon: Icons.shopping_bag_outlined,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('\$${product['price']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildInfoTab(AsyncValue<List<Map<String, dynamic>>> teamAsync, Business business) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sobre nosotros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(business.description),
          const SizedBox(height: 24),
          const Text('Nuestro Equipo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          teamAsync.when(
            data: (team) {
              if (team.isEmpty) return const Text('Aún no hay miembros en el equipo.');
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: team.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final member = team[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text((member['name'] ?? 'U').substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(member['name'] ?? 'Desconocido', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(member['role'] ?? 'Sin cargo asignado'),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, __) => Text('Error al cargar equipo: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(Business business) {
    final hasGallery = business.galleryImages.isNotEmpty;
    final hasImage = business.imageUrl.isNotEmpty;
    if (hasGallery || hasImage) {
      return AppCachedImage(
        imageUrl: hasGallery ? business.galleryImages.first : business.imageUrl,
        fit: BoxFit.cover,
      );
    }
    return Container(color: const Color(0xFFF1F5F9), child: Center(child: Icon(Icons.storefront_outlined, size: 48, color: AppColors.textSecondary)));
  }

  Widget _buildStat(String value, String label, {bool isStar = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            if (isStar) const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildDivider() => const VerticalDivider(color: Color(0xFFF1F5F9), thickness: 1, width: 1, indent: 8, endIndent: 8);

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: (color ?? AppColors.primary).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.bodySmall.copyWith(color: color ?? AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: Colors.white, child: _tabBar);
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

