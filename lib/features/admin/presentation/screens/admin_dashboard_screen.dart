import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/business.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/admin/presentation/providers/admin_providers.dart';
import 'package:sistema_gestion_servicios_multiplataforma/core/theme/app_colors.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/admin/presentation/screens/new_post_flow.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/admin/presentation/screens/new_product_flow.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/admin/presentation/screens/new_service_flow.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/admin/presentation/screens/team_management_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'manage_products_screen.dart';
import 'manage_gallery_screen.dart';
import 'manage_services_screen.dart';
import 'manage_bookings_screen.dart';
import 'admin_finances_screen.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/screens/notifications_screen.dart';
import 'package:sistema_gestion_servicios_multiplataforma/core/widgets/app_cached_image.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(adminBusinessProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('No se encontró el negocio.'));
          }
          return _buildDashboard(context, ref, business);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDashboard(
      BuildContext context, WidgetRef ref, Business business) {
    final servicesAsync = ref.watch(adminServicesProvider);
    final postsAsync = ref.watch(adminPostsProvider);
    final todayStats = ref.watch(adminTodayStatsProvider);
    final todayCitas = todayStats['citas'] as int;
    final todayCanceladas = todayStats['canceladas'] as int;
    final todayIngresos = todayStats['ingresos'] as double;
    final ingresosFmt = '\$${NumberFormat.compact(locale: 'es').format(todayIngresos)}';

    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weekAppointments = ref.watch(adminFinancesProvider((business.id, weekStart, weekEnd))).valueOrNull ?? [];
    final weekRevenue = weekAppointments.where((a) => a.status != 'cancelled').fold<double>(0, (s, a) => s + a.totalPrice);
    final weekRevenueFmt = '\$${NumberFormat.compact(locale: 'es').format(weekRevenue)}';

    // Per-day revenue (Mon=0 … Sun=6)
    final dayRevenues = List<double>.filled(7, 0.0);
    final Map<String, int> memberCitas = {};
    final Map<String, double> memberIngresos = {};
    for (final appt in weekAppointments) {
      if (appt.status != 'cancelled') {
        final d = appt.dateTime.weekday - 1;
        if (d >= 0 && d < 7) dayRevenues[d] += appt.totalPrice;
        if (appt.professionalId.isNotEmpty) {
          memberCitas[appt.professionalId] = (memberCitas[appt.professionalId] ?? 0) + 1;
          memberIngresos[appt.professionalId] = (memberIngresos[appt.professionalId] ?? 0.0) + appt.totalPrice;
        }
      }
    }
    final maxDayRevenue = dayRevenues.reduce((a, b) => a > b ? a : b);
    final totalWeekCitas = memberCitas.values.fold(0, (a, b) => a + b);

    final workRequests = ref.watch(adminWorkRequestsProvider).valueOrNull ?? [];
    final pendingToday = ref.watch(adminPendingTodayProvider);
    final totalAlerts = workRequests.length + (pendingToday > 0 ? 1 : 0);

    return CustomScrollView(
      slivers: [
        // Orange Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: const BoxDecoration(
              color: Color(0xFFF97316),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            height: 16,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Admin',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: Colors.white),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _pickAvatar(business.id),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha:0.5), width: 2),
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white.withValues(alpha:0.1),
                              child: business.avatarUrl.isNotEmpty
                                  ? AppCachedImage(
                                      key: ValueKey(business.avatarUrl),
                                      imageUrl: business.avatarUrl,
                                      width: 64,
                                      height: 64,
                                      borderRadius: BorderRadius.circular(32),
                                    )
                                  : const Icon(Icons.store,
                                      color: Colors.white, size: 28),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF97316),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                          Text(
                            DateFormat('EEEE, d de MMMM yyyy', 'es')
                                .format(DateTime.now()),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white.withValues(alpha:0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Stats Grid
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            delegate: SliverChildListDelegate([
              _buildStatCard('Ingresos hoy', ingresosFmt, Icons.attach_money,
                  'hoy', isUp: todayIngresos > 0),
              _buildStatCard('Citas hoy', '$todayCitas', Icons.calendar_today,
                  'hoy', isUp: todayCitas > 0),
              _buildStatCard('Ocupación',
                  todayCitas + todayCanceladas == 0
                      ? '0%'
                      : '${(todayCitas * 100 ~/ (todayCitas + todayCanceladas))}%',
                  Icons.access_time, 'hoy', isUp: todayCitas > 0),
              _buildStatCard('Cancelaciones', '$todayCanceladas',
                  Icons.error_outline, 'hoy', isUp: todayCanceladas == 0),
            ]),
          ),
        ),

        // Weekly Chart Placeholder
        SliverToBoxAdapter(
          child: _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('Ingresos de la semana',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminFinancesScreen(businessId: business.id),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text('Detalle',
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 12)),
                          Icon(Icons.chevron_right,
                              size: 14, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(weekRevenueFmt,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_view_week,
                                size: 10, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text('Esta semana',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 125,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar(dayRevenues[0], maxDayRevenue, 'Lun', isActive: now.weekday == 1),
                      _buildBar(dayRevenues[1], maxDayRevenue, 'Mar', isActive: now.weekday == 2),
                      _buildBar(dayRevenues[2], maxDayRevenue, 'Mié', isActive: now.weekday == 3),
                      _buildBar(dayRevenues[3], maxDayRevenue, 'Jue', isActive: now.weekday == 4),
                      _buildBar(dayRevenues[4], maxDayRevenue, 'Vie', isActive: now.weekday == 5),
                      _buildBar(dayRevenues[5], maxDayRevenue, 'Sáb', isActive: now.weekday == 6),
                      _buildBar(dayRevenues[6], maxDayRevenue, 'Dom', isActive: now.weekday == 7),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildLegend(const Color(0xFFF97316), 'Hoy'),
                    const SizedBox(width: 16),
                    _buildLegend(const Color(0xFFC084FC), 'Otros días'),
                    const Spacer(),
                    Text('${todayCitas + todayCanceladas} citas hoy',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Gallery Images Management Section
        SliverToBoxAdapter(
          child: _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('Imágenes del negocio',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                    GestureDetector(
                      onTap: () => _addGalleryImage(context, business.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('Agregar',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Estas son las fotos que ven los usuarios en Explorar',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 16),
                _buildGalleryStrip(context, business),
              ],
            ),
          ),
        ),

        // Publish Content Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Publicar contenido',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                postsAsync.when(
                  data: (posts) => Text('${posts.length} publicados',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () =>
                      _addContent(context, ref, business.id, 'producto'),
                  child: _buildPublishCard('Producto', 'Agregar al catálogo',
                      Icons.inventory_2_outlined, const Color(0xFFC084FC)),
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: GestureDetector(
                  onTap: () => _addContent(context, ref, business.id, 'post'),
                  child: _buildPublishCard('Foto / Post', 'Publicar en galería',
                      Icons.image_outlined, const Color(0xFFFB923C)),
                )),
              ],
            ),
          ),
        ),

        // Action Buttons Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSmallActionButton(
                    Icons.calendar_today_outlined,
                    'Citas',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ManageBookingsScreen(businessId: business.id)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSmallActionButton(
                    Icons.inventory_2_outlined,
                    'Ver productos',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ManageProductsScreen(businessId: business.id)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSmallActionButton(
                    Icons.image_outlined,
                    'Ver galería',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ManageGalleryScreen(businessId: business.id)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSmallActionButton(
                    Icons.cut_outlined,
                    'Servicios',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ManageServicesScreen(businessId: business.id)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Services Section
        SliverToBoxAdapter(
          child: _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mis servicios',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                          const Text('Visibles en Explorar',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Gestionar >',
                        style:
                            TextStyle(color: AppColors.primary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                servicesAsync.when(
                  data: (services) {
                    if (services.isEmpty) {
                      return const Center(
                          child: Text('No hay servicios registrados.'));
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: services.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _buildServiceItem(
                            service.name,
                            service.price.toString(),
                            service.duration,
                            Icons.cut_outlined);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () =>
                      _addContent(context, ref, business.id, 'servicio'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Color(0xFFF1F5F9)),
                    backgroundColor: const Color(0xFFF8FAFC),
                  ),
                  child: Text('+ Agregar servicio',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),

        // Team Performance Section
        SliverToBoxAdapter(
          child: _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('Rendimiento del equipo',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TeamManagementScreen(businessId: business.id),
                          ),
                        );
                      },
                      child: Text('Ver todos >',
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('businesses')
                      .doc(business.id)
                      .collection('team')
                      .limit(4)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final members = snapshot.data?.docs ?? [];
                    if (members.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.people_outline,
                                  size: 32, color: AppColors.textSecondary),
                              const SizedBox(height: 8),
                              const Text('No hay miembros en el equipo',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: members.map((doc) {
                        final m = doc.data() as Map<String, dynamic>;
                        final name = m['name'] ?? 'Sin nombre';
                        final initials = name
                            .split(' ')
                            .take(2)
                            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                            .join();
                        final userId = m['userId'] ?? doc.id;
                        final citas = memberCitas[userId] ?? 0;
                        final ingresos = memberIngresos[userId] ?? 0.0;
                        final performance = totalWeekCitas > 0 ? citas / totalWeekCitas : 0.0;
                        final ingresosFmtMember = '\$${NumberFormat.compact(locale: 'es').format(ingresos)}';
                        return _buildTeamMember(
                          name,
                          initials,
                          performance.clamp(0.0, 1.0),
                          ingresosFmtMember,
                          '$citas',
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Alerts Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Text('Alertas',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: totalAlerts > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: Text('$totalAlerts',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Column(
            children: [
              if (totalAlerts == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay alertas por el momento',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              if (workRequests.isNotEmpty)
                _buildAlertItem(
                  Icons.person_add_outlined,
                  '${workRequests.length} solicitud${workRequests.length == 1 ? '' : 'es'} de ingreso al equipo pendiente${workRequests.length == 1 ? '' : 's'}',
                  'Ver equipo',
                  const Color(0xFFF97316),
                ),
              if (pendingToday > 0)
                _buildAlertItem(
                  Icons.pending_actions_outlined,
                  '$pendingToday cita${pendingToday == 1 ? '' : 's'} de hoy sin confirmar',
                  'Ver citas',
                  const Color(0xFFF59E0B),
                ),
            ],
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
      ],
    );
  }

  void _addContent(
      BuildContext context, WidgetRef ref, String businessId, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (type == 'post') {
          return NewPostFlow(businessId: businessId);
        } else if (type == 'producto') {
          return NewProductFlow(businessId: businessId);
        } else {
          return NewServiceFlow(businessId: businessId);
        }
      },
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, String percent,
      {required bool isUp}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: (isUp
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withValues(alpha:0.05),
                    shape: BoxShape.circle),
                child: Icon(icon,
                    size: 18,
                    color: isUp
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444)),
              ),
              Row(
                children: [
                  Icon(isUp ? Icons.north_east : Icons.south_east,
                      size: 10,
                      color: isUp
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444)),
                  const SizedBox(width: 2),
                  Text(percent,
                      style: TextStyle(
                          color: isUp
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: child,
    );
  }

  Widget _buildBar(double value, double maxValue, String label, {bool isActive = false}) {
    final fraction = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    final barHeight = (fraction * 90).clamp(4.0, 90.0);
    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: barHeight,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFF97316)
                : const Color(0xFFC084FC).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: isActive
              ? Center(
                  child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle)))
              : null,
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: isActive
                    ? const Color(0xFFF97316)
                    : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
                color: Color(0xFFF97316), shape: BoxShape.circle),
          ),
      ],
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(text,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  void _addGalleryImage(BuildContext context, String businessId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Agregar imagen',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text('Elige cómo agregar la imagen',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              // Option 1: From device gallery
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: Color(0xFFF97316)),
                ),
                title: const Text('Desde galería',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Seleccionar de tus fotos',
                    style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImageFromGallery(businessId);
                },
              ),
              const SizedBox(height: 8),
              // Option 2: From URL
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC084FC).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.link, color: Color(0xFFC084FC)),
                ),
                title: const Text('Desde URL',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pegar enlace de imagen',
                    style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _addGalleryImageFromUrl(context, businessId);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery(String businessId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      final mimeType = picked.mimeType ?? 'image/jpeg';
      final dataUri = 'data:$mimeType;base64,$base64Str';

      final doc = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .get();
      final data = doc.data() ?? {};
      final images = List<String>.from(data['galleryImages'] ?? []);
      images.add(dataUri);
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .update({'galleryImages': images});
    }
  }

  void _addGalleryImageFromUrl(BuildContext context, String businessId) {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Agregar desde URL',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa la URL de la imagen',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'https://ejemplo.com/imagen.jpg',
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF97316)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (urlController.text.trim().isNotEmpty) {
                final doc = await FirebaseFirestore.instance
                    .collection('businesses')
                    .doc(businessId)
                    .get();
                final data = doc.data() ?? {};
                final images = List<String>.from(data['galleryImages'] ?? []);
                images.add(urlController.text.trim());
                await FirebaseFirestore.instance
                    .collection('businesses')
                    .doc(businessId)
                    .update({'galleryImages': images});
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removeGalleryImage(
      String businessId, List<String> images, int index) async {
    final updatedImages = List<String>.from(images);
    updatedImages.removeAt(index);
    await FirebaseFirestore.instance
        .collection('businesses')
        .doc(businessId)
        .update({'galleryImages': updatedImages});
  }

  Widget _buildPublishCard(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Text(subtitle,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSmallActionButton(
      IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFC084FC)),
            const SizedBox(width: 6),
            Text(text,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 12, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(
      String name, String price, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 16, color: Colors.black87),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
                Text('$price · $time',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String initials, double performance,
      String earnings, String appointments) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text('${(performance * 100).toInt()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: performance,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: AppColors.primary,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(earnings,
                  style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              Text('$appointments cita${appointments == '1' ? '' : 's'}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
      IconData icon, String message, String action, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(action,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryStrip(BuildContext context, Business business) {
    final images = business.galleryImages;

    if (images.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 32, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              Text('No hay imágenes aún',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              Text('Agrega fotos de tu negocio',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = images[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AppCachedImage(
                    key: ValueKey(imageUrl),
                    imageUrl: imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () =>
                        _removeGalleryImage(business.id, images, index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAvatar(String businessId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 500, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      final mimeType = picked.mimeType ?? 'image/jpeg';
      final dataUri = 'data:$mimeType;base64,$base64Str';

      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .update({'avatarUrl': dataUri, 'imageUrl': dataUri});
    }
  }
}

