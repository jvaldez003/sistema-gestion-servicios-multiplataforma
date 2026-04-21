import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/business.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/domain/models/appointment.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/booking_notifier.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/business_details_providers.dart';
import '../providers/booking_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class BookingFlowScreen extends ConsumerWidget {
  final Business business;

  const BookingFlowScreen({super.key, required this.business});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          bookingState.currentStep == 0
              ? 'Seleccionar Servicios'
              : bookingState.currentStep == 1
                  ? 'Elegir Horario'
                  : 'Confirmar Reserva',
          style: AppTypography.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (bookingState.currentStep > 0) {
              ref.read(bookingStateProvider.notifier).previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= bookingState.currentStep
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: _buildStepContent(bookingState.currentStep, business),
          ),
          _buildBottomBar(context, ref, bookingState, business),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step, Business business) {
    switch (step) {
      case 0:
        return _SelectServicesStep(businessId: business.id);
      case 1:
        return _SchedulingStep(businessId: business.id);
      case 2:
        return _SummaryStep(business: business);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref,
      BookingState state, Business business) {
    bool canContinue = false;
    if (state.currentStep == 0) canContinue = state.selectedServices.isNotEmpty;
    if (state.currentStep == 1) {
      canContinue = state.selectedDate != null &&
          state.selectedTime != null &&
          state.professionalId != null &&
          state.professionalId!.isNotEmpty;
    }
    if (state.currentStep == 2) canContinue = true;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.selectedServices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total (${state.selectedServices.length} serv.)',
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      '\$${state.totalPrice.toStringAsFixed(0)}',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: canContinue
                  ? () => _handleContinue(context, ref, state, business)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                state.currentStep == 2 ? 'Confirmar Reserva' : 'Continuar',
                style: AppTypography.titleMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue(
      BuildContext context, WidgetRef ref, BookingState state, Business business) async {
    if (state.currentStep < 2) {
      ref.read(bookingStateProvider.notifier).nextStep();
    } else {
      // Finalize booking
      final auth = ref.read(authStateProvider).value;
      if (auth == null) return;

      final appointment = Appointment(
        userId: auth.id,
        businessId: business.id,
        businessName: business.name,
        serviceIds: state.selectedServices.map((s) => s.id).toList(),
        serviceNames: state.selectedServices.map((s) => s.name).toList(),
        totalPrice: state.totalPrice,
        dateTime: DateTime(
          state.selectedDate!.year,
          state.selectedDate!.month,
          state.selectedDate!.day,
          int.parse(state.selectedTime!.split(':')[0]),
          int.parse(state.selectedTime!.split(':')[1]),
        ),
        professionalId: state.professionalId!,
        professionalName: state.professionalName!,
        createdAt: DateTime.now(),
      );

      try {
        await ref.read(bookingRepositoryProvider).createAppointment(appointment);
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Center(child: Icon(Icons.check_circle, color: AppColors.success, size: 60)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('¡Reserva Exitosa!', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  const Text('Tu cita ha sido agendada correctamente.', textAlign: TextAlign.center),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // dialog
                    Navigator.of(context).pop(); // booking screen
                  },
                  child: const Text('Ir a mis citas'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear reserva: $e')),
          );
        }
      }
    }
  }
}

class _SelectServicesStep extends ConsumerWidget {
  final String businessId;

  const _SelectServicesStep({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(businessServicesProvider(businessId));
    final bookingState = ref.watch(bookingStateProvider);

    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return const Center(child: Text('No hay servicios disponibles.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final isSelected = bookingState.selectedServices.any((s) => s.id == service.id);

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                onTap: () => ref.read(bookingStateProvider.notifier).toggleService(service),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                title: Text(service.name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(service.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(service.duration, style: AppTypography.bodySmall),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${service.price.toStringAsFixed(0)}', 
                      style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => ref.read(bookingStateProvider.notifier).toggleService(service),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
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
}

class _SchedulingStep extends ConsumerWidget {
  final String businessId;

  const _SchedulingStep({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingStateProvider);
    final teamAsync = ref.watch(businessTeamProvider(businessId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selecciona un profesional', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          teamAsync.when(
            data: (team) {
              return SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: team.length,
                  itemBuilder: (context, index) {
                    final member = team[index];
                    final memberId = member['userId'] ?? member['id'] ?? '';
                    final isSelected = bookingState.professionalId == memberId;
                    return GestureDetector(
                      onTap: () => ref.read(bookingStateProvider.notifier).selectProfessional(memberId, member['name']),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: AppSpacing.md),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: isSelected ? AppColors.primary : AppColors.border,
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: Text(member['name'][0].toUpperCase(), style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(member['name'], style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
            error: (err, __) => Text('Error: $err'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Fecha', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: bookingState.selectedDate ?? DateTime.now(),
            currentDay: DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(bookingState.selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              ref.read(bookingStateProvider.notifier).selectDate(selectedDay);
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Horario disponible', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          if (bookingState.selectedDate != null)
            Consumer(
              builder: (context, ref, child) {
                final appointmentsAsync = ref.watch(businessAppointmentsProvider((businessId, bookingState.selectedDate!)));
                
                return appointmentsAsync.when(
                  data: (appointments) {
                    final occupiedTimes = appointments
                        .where((a) => a.professionalId == bookingState.professionalId && a.status != 'cancelled')
                        .map((a) => DateFormat('HH:mm').format(a.dateTime))
                        .toSet();

                    final team = teamAsync.value ?? [];
                    final selectedMember = team.firstWhere(
                      (m) => (m['userId'] ?? m['id']) == bookingState.professionalId,
                      orElse: () => <String, dynamic>{},
                    );
                    
                    final List<String> availableHours = (selectedMember['workingHours'] as List?)?.cast<String>() ?? 
                        ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00'];

                    final now = DateTime.now();
                    final isToday = isSameDay(bookingState.selectedDate, now);

                    return Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: availableHours.map((time) {
                        final isSelected = bookingState.selectedTime == time;
                        final isOccupied = occupiedTimes.contains(time);
                        
                        bool isPassed = false;
                        if (isToday) {
                          try {
                            final parts = time.split(':');
                            final hour = int.parse(parts[0]);
                            final minute = int.parse(parts[1]);
                            final slotDateTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              hour,
                              minute,
                            );
                            // 30 minutes buffer
                            isPassed = slotDateTime.isBefore(now.add(const Duration(minutes: 30)));
                          } catch (e) {
                            isPassed = false;
                          }
                        }

                        final bool isDisabled = isOccupied || isPassed;
                        
                        return ChoiceChip(
                          label: Text(
                            time,
                            style: TextStyle(
                              decoration: isDisabled ? TextDecoration.lineThrough : null,
                              color: isDisabled ? Colors.grey : (isSelected ? Colors.white : AppColors.textPrimary),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: isDisabled ? null : (_) => ref.read(bookingStateProvider.notifier).selectTime(time),
                          selectedColor: AppColors.primary,
                          disabledColor: Colors.grey.shade200,
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, __) => Text('Error al cargar disponibilidad: $err'),
                );
              },
            )
          else
            const Text('Selecciona una fecha primero'),
        ],
      ),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  final Business business;

  const _SummaryStep({required this.business});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(bookingStateProvider);
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(business.name, style: AppTypography.titleLarge),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildSummaryRow(Icons.calendar_today, 'Fecha', DateFormat('EEEE, d MMMM', 'es').format(state.selectedDate!)),
                  const SizedBox(height: 16),
                  _buildSummaryRow(Icons.access_time, 'Hora', state.selectedTime!),
                  const SizedBox(height: 16),
                  _buildSummaryRow(Icons.person_outline, 'Profesional', state.professionalName!),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Servicios seleccionados', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            ...state.selectedServices.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.name, style: AppTypography.bodyMedium),
                  Text('\$${s.price.toStringAsFixed(0)}', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.bodySmall),
            Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
