import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/business.dart';
import '../../domain/models/booking.dart';
import '../providers/booking_providers.dart';
import '../providers/business_details_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Business business;

  const BookingScreen({super.key, required this.business});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedTime;
  Map<String, dynamic>? _selectedService;

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(businessServicesProvider(widget.business.id));
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reservar Cita'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: widget.business.avatarUrl.isNotEmpty
                      ? NetworkImage(widget.business.avatarUrl)
                      : null,
                  child: widget.business.avatarUrl.isEmpty
                      ? Text(widget.business.name.substring(0, 1).toUpperCase())
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.business.name, style: AppTypography.titleMedium),
                      Text(widget.business.category, style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Service Selection
            Text('Selecciona un Servicio', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            servicesAsync.when(
              data: (services) {
                if (services.isEmpty) {
                  return const Text('No hay servicios disponibles');
                }
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final isSelected = _selectedService?['id'] == service['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedService = service),
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                service['name'] ?? '',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${service['price']}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isSelected ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => Text('Error: $err'),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Date Selection
            Text('Selecciona una Fecha', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Time Selection
            Text('Selecciona un Horario', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _timeSlots.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      time,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (_selectedService != null && _selectedTime != null)
                    ? () => _confirmBooking(context, authState.value?.id, authState.value?.name)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Confirmar Reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context, String? userId, String? userName) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para reservar')),
      );
      return;
    }

    final bookingNode = Booking(
      id: '', // Will be generated by Firestore
      businessId: widget.business.id,
      businessName: widget.business.name,
      userId: userId,
      userName: userName ?? 'Usuario',
      serviceName: _selectedService!['name'],
      price: double.tryParse(_selectedService!['price']?.toString() ?? '0') ?? 0.0,
      date: _selectedDay,
      time: _selectedTime!,
    );

    try {
      await ref.read(bookingRepositoryProvider).createBooking(bookingNode);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¡Reserva Exitosa!'),
            content: Text('Tu cita para ${_selectedService!['name']} ha sido agendada.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to profile
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reservar: $e')),
        );
      }
    }
  }
}
