import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../../home/domain/models/appointment.dart';
import '../../../home/presentation/providers/booking_providers.dart';

class ManageBookingsScreen extends ConsumerStatefulWidget {
  final String businessId;

  const ManageBookingsScreen({super.key, required this.businessId});

  @override
  ConsumerState<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends ConsumerState<ManageBookingsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(
      businessAppointmentsProvider((widget.businessId, _selectedDate)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Gestión de Citas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: _buildBookingsList(appointmentsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 14, // Dos semanas
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index - 2));
            final isSelected = date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E', 'es').format(date).substring(0, 3).toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingsList(AsyncValue<List<Appointment>> appointmentsAsync) {
    return appointmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error al cargar citas', style: Theme.of(context).textTheme.bodyMedium),
      ),
      data: (appointments) {
        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary.withValues(alpha:0.5)),
                const SizedBox(height: 16),
                Text(
                  'No hay citas para esta fecha',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: appointments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildBookingCard(appointments[index]),
        );
      },
    );
  }

  Widget _buildBookingCard(Appointment appointment) {
    Color statusColor;
    String statusText;

    switch (appointment.status) {
      case 'confirmed':
        statusColor = const Color(0xFF10B981);
        statusText = 'Confirmada';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusText = 'Cancelada';
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Pendiente';
    }

    final timeHour = DateFormat('h:mm').format(appointment.dateTime);
    final timeAmPm = DateFormat('a').format(appointment.dateTime).toUpperCase();
    final price = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0)
        .format(appointment.totalPrice);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        timeHour,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeAmPm,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.serviceNames.join(', '),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.professionalName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            price,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (appointment.status == 'pending') ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        await ref.read(bookingRepositoryProvider).updateAppointmentStatus(
                          appointment.id!,
                          'cancelled',
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(bookingRepositoryProvider).updateAppointmentStatus(
                          appointment.id!,
                          'confirmed',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Aceptar'),
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
}
