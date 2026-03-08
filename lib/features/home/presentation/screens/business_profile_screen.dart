import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/business.dart';

class BusinessProfileScreen extends StatefulWidget {
  final Business business;

  const BusinessProfileScreen({super.key, required this.business});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen>
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
              background: Image.network(
                widget.business.imageUrl,
                fit: BoxFit.cover,
              ),
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
                            backgroundImage:
                                NetworkImage(widget.business.avatarUrl),
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
                        _buildStat('48', 'Posts'),
                        _buildStat('2.340', 'Seguidores'),
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

          // Tab Content (Posts as example)
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPostItem(),
                childCount: 3,
              ),
            ),
          ),
        ],
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

  Widget _buildPostItem() {
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
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text('CM',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Carlos Méndez',
                        style: AppTypography.bodySmall
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text('hace 2h  •  Corte de cabello',
                        style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border,
                    size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Image.network(
              'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?auto=format&fit=crop&q=80&w=800',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
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
