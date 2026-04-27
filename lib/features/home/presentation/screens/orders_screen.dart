import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/appointment.dart';
import '../providers/booking_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(userAppointmentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mis Pedidos',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          // Solo mostramos citas que NO estén canceladas (son las "compras" válidas)
          final orders = appointments
              .where((a) => a.status != 'cancelled')
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (orders.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              return _OrderCard(appointment: orders[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Error al cargar pedidos', style: AppTypography.titleMedium),
              const SizedBox(height: 8),
              Text('$e', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF6366F1),
              size: 64,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'No tienes pedidos aún',
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Aquí aparecerá el historial de tus compras de productos y servicios.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () {
              // Cambia al tab Explorar (índice 0) y regresa al HomeScreen
              ref.read(homeTabIndexProvider.notifier).state = 0;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Ir a explorar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Appointment appointment;

  const _OrderCard({required this.appointment});

  Color get _statusColor {
    switch (appointment.status) {
      case 'confirmed':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.textSecondary;
    }
  }

  String get _statusLabel {
    switch (appointment.status) {
      case 'confirmed':
        return 'Confirmado';
      case 'completed':
        return 'Completado';
      case 'pending':
        return 'Pendiente';
      default:
        return appointment.status;
    }
  }

  IconData get _statusIcon {
    switch (appointment.status) {
      case 'confirmed':
        return Icons.check_circle_outline_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: tienda + status ───────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_outlined,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    appointment.businessName,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Servicios solicitados ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              'Servicios solicitados',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...appointment.serviceNames.map(
            (name) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // ── Footer: precio + fecha ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                // Precio
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.attach_money_rounded,
                          color: Color(0xFF10B981), size: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '\$${appointment.totalPrice.toStringAsFixed(2)}',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Fecha
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(appointment.dateTime),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
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

  String _formatDate(DateTime dt) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
