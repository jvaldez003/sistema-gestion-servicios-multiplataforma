import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Orange Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bolt,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'FlowServ Admin',
                            style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Badge(
                          label: Text('1'),
                          child: Icon(Icons.notifications_none,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'BarberShop Premium',
                    style: AppTypography.h2.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Viernes, 6 de marzo 2026',
                    style: AppTypography.bodySmall
                        .copyWith(color: Colors.white.withOpacity(0.8)),
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
                _buildStatCard(
                    'Ingresos hoy', '\$580k', Icons.attach_money, '18.5%',
                    isUp: true),
                _buildStatCard('Citas hoy', '15', Icons.calendar_today, '8.2%',
                    isUp: true),
                _buildStatCard('Ocupación', '87%', Icons.access_time, '5.1%',
                    isUp: true),
                _buildStatCard('Cancelaciones', '2', Icons.error_outline, '33%',
                    isUp: false),
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
                      Text('Ingresos de la semana',
                          style: AppTypography.titleLarge
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('Detalle >',
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('\$2.3M',
                          style: AppTypography.h2
                              .copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('↑ 24.3% vs semana pasada',
                            style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Simple Bar Chart
                  SizedBox(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar(40, 'Lun'),
                        _buildBar(30, 'Mar'),
                        _buildBar(60, 'Mié'),
                        _buildBar(45, 'Jue'),
                        _buildBar(80, 'Vie', isActive: true),
                        _buildBar(65, 'Sáb'),
                        _buildBar(20, 'Dom'),
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
                      const Text('60 citas totales',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
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
                      style: AppTypography.titleLarge
                          .copyWith(fontWeight: FontWeight.bold)),
                  const Text('0 publicados hoy',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
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
                      child: _buildPublishCard(
                          'Producto',
                          'Agregar al catálogo',
                          Icons.inventory_2_outlined,
                          const Color(0xFFC084FC))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildPublishCard(
                          'Foto / Post',
                          'Publicar en galería',
                          Icons.image_outlined,
                          const Color(0xFFFB923C))),
                ],
              ),
            ),
          ),

          // Action Buttons Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  _buildSmallActionButton(
                      Icons.inventory_2_outlined, 'Ver productos'),
                  const SizedBox(width: 12),
                  _buildSmallActionButton(Icons.image_outlined, 'Ver galería'),
                  const SizedBox(width: 12),
                  _buildSmallActionButton(Icons.cut_outlined, 'Servicios'),
                ],
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mis servicios',
                              style: AppTypography.titleLarge
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const Text('Visibles en Explorar',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                      Text('Gestionar >',
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildServiceItem('Corte Clásico', '\$25k', '30 min',
                          Icons.cut_outlined),
                      _buildServiceItem('Corte + Fade', '\$35k', '45 min',
                          Icons.local_bar_outlined),
                      _buildServiceItem('Arreglo de b...', '\$20k', '20 min',
                          Icons.send_outlined),
                      _buildServiceItem('Corte + Barba', '\$50k', '60 min',
                          Icons.face_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {},
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

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: (isUp
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(icon,
                    size: 16,
                    color: isUp
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444)),
              ),
              Row(
                children: [
                  Icon(isUp ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: isUp
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444)),
                  const SizedBox(width: 4),
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
                  style:
                      AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
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

  Widget _buildBar(double height, String label, {bool isActive = false}) {
    return Column(
      children: [
        if (isActive)
          Text('\$580k',
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 38,
          height: height,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFF97316)
                : const Color(0xFFC084FC).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
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
                color: color.withOpacity(0.1),
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
              Text(title,
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSmallActionButton(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFFC084FC)),
            const SizedBox(width: 8),
            Text(text,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 14, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
                Text('$price · $time',
                    style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
