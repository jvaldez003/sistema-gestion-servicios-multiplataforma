import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/business.dart';
import '../providers/business_details_providers.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  final Business business;

  const BusinessProfileScreen({super.key, required this.business});

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
    final postsAsync = ref.watch(businessPostsProvider(widget.business.id));
    final servicesAsync =
        ref.watch(businessServicesProvider(widget.business.id));
    final productsAsync =
        ref.watch(businessProductsProvider(widget.business.id));

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
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined,
                      color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildCoverImage(),
            ),
          ),

          // Profile Info Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary,
                            backgroundImage:
                                widget.business.avatarUrl.isNotEmpty
                                    ? NetworkImage(widget.business.avatarUrl)
                                    : null,
                            child: widget.business.avatarUrl.isEmpty
                                ? Text(
                                    widget.business.name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: AppTypography.h1
                                        .copyWith(color: Colors.white),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Seguir'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Reservar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Name & Category
                  Text(
                    widget.business.name,
                    style:
                        AppTypography.h2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '@${widget.business.name.toLowerCase().replaceAll(' ', '')}',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Text('•  ${widget.business.category}  •  Bogotá',
                          style: AppTypography.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Description
                  Text(
                    '✂️ ${widget.business.description}',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick Stats
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        postsAsync.when(
                          data: (posts) =>
                              _buildStat('${posts.length}', 'Posts'),
                          loading: () => _buildStat('...', 'Posts'),
                          error: (_, __) => _buildStat('0', 'Posts'),
                        ),
                        _buildStat(
                            '${widget.business.followerCount}', 'Seguidores'),
                        _buildStat('${widget.business.rating}', 'Rating',
                            isStar: true),
                        _buildStat(
                            '${widget.business.professionalCount}', 'Equipo'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Info Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildInfoChip(Icons.location_on_outlined,
                            '${widget.business.distance} km'),
                        _buildInfoChip(
                            Icons.phone_outlined, '+57 300 123 4567'),
                        _buildInfoChip(Icons.access_time, 'Hoy 9AM-7PM',
                            color: const Color(0xFF10B981)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Tabs
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
                  Tab(
                      icon: Icon(Icons.grid_view_rounded, size: 20),
                      text: 'Posts'),
                  Tab(
                      icon: Icon(Icons.layers_outlined, size: 20),
                      text: 'Servicios'),
                  Tab(
                      icon: Icon(Icons.shopping_bag_outlined, size: 20),
                      text: 'Tienda'),
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
                _buildPostsTab(postsAsync),
                _buildServicesTab(servicesAsync),
                _buildProductsTab(productsAsync),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(AsyncValue<List<Map<String, dynamic>>> postsAsync) {
    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('Aún no hay publicaciones.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: posts.length,
          itemBuilder: (context, index) => _buildPostItem(posts[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildServicesTab(
      AsyncValue<List<Map<String, dynamic>>> servicesAsync) {
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
              title: Text(service['name'] ?? ''),
              subtitle: Text(service['duration'] ?? ''),
              trailing: Text(
                '\$${service['price']}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildProductsTab(
      AsyncValue<List<Map<String, dynamic>>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(
              child: Text('Aún no hay productos en la tienda.'));
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
                    child: Container(
                      color: Colors.grey[200],
                      width: double.infinity,
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['name'] ?? '',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(
                          '\$${product['price']}',
                          style: const TextStyle(
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
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sobre nosotros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(widget.business.description),
          const SizedBox(height: 20),
          const Text('Ubicación',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('Bogotá, Colombia'),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    final hasGallery = widget.business.galleryImages.isNotEmpty;
    final hasImage = widget.business.imageUrl.isNotEmpty;

    if (hasGallery) {
      return Image.network(
        widget.business.galleryImages.first,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    } else if (hasImage) {
      return Image.network(
        widget.business.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(widget.business.name,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, {bool isStar = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: AppTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.bold)),
            if (isStar) Icon(Icons.star_rounded, color: Colors.amber, size: 18),
          ],
        ),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  backgroundImage: widget.business.avatarUrl.isNotEmpty
                      ? NetworkImage(widget.business.avatarUrl)
                      : null,
                  child: widget.business.avatarUrl.isEmpty
                      ? Text(widget.business.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10))
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.business.name,
                        style: AppTypography.bodySmall
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(post['title'] ?? 'Novedad',
                        style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border,
                    size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
          if (post['imageUrl'] != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Image.network(
                post['imageUrl'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
