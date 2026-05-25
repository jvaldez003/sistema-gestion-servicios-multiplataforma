import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/appointment.dart';
import '../providers/booking_providers.dart';
import '../providers/orders_notifier.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(userAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mis Pedidos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          final orders = appointments
              .where((a) => a.status != 'cancelled')
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (orders.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: orders.length,
            itemBuilder: (context, index) => _OrderCard(appointment: orders[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
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
              size: 56,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'No tienes pedidos aún',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Cuando reserves un servicio o compres un producto aparecerá aquí.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Appointment appointment;

  const _OrderCard({required this.appointment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusConfig = _getStatusConfig(appointment.status);
    final statusColor = statusConfig.color;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: AppColors.borderDark)
            : Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: isDark
            ? null
            : [
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.06),
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
                  child: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment.businessName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusConfig.icon, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        statusConfig.label,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.content_cut_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Servicios',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: appointment.serviceNames.map((name) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Theme.of(context).dividerColor),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.attach_money_rounded, color: Color(0xFF10B981), size: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '\$${appointment.totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(appointment.dateTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (appointment.status == 'pending' || appointment.status == 'confirmed') ...[
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleCancel(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref.read(ordersControllerProvider.notifier).startRescheduling(context, appointment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Reagendar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar cita?'),
        content: const Text('¿Estás seguro de que deseas cancelar esta cita? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, volver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(ordersControllerProvider.notifier).cancelAppointment(appointment.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita cancelada correctamente')),
        );
      }
    }
  }

  String _formatDate(DateTime dt) {
    final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return _StatusConfig(label: 'PENDIENTE', icon: Icons.access_time_rounded, color: const Color(0xFFF59E0B));
      case 'confirmed':
        return _StatusConfig(label: 'CONFIRMADO', icon: Icons.check_circle_rounded, color: const Color(0xFF6366F1));
      case 'completed':
        return _StatusConfig(label: 'COMPLETADO', icon: Icons.task_alt_rounded, color: const Color(0xFF10B981));
      case 'cancelled':
        return _StatusConfig(label: 'CANCELADO', icon: Icons.cancel_rounded, color: AppColors.error);
      default:
        return _StatusConfig(label: 'DESCONOCIDO', icon: Icons.help_outline_rounded, color: Colors.grey);
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color color;
  _StatusConfig({required this.label, required this.icon, required this.color});
}
