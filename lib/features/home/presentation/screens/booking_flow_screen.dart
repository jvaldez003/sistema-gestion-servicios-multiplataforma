import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/business.dart';
import '../../domain/models/appointment.dart';
import '../../domain/models/service.dart';
import '../providers/booking_notifier.dart';
import '../providers/booking_providers.dart';
import '../providers/business_details_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class BookingFlowScreen extends ConsumerWidget {
  final Business business;
  final Appointment? appointmentToReschedule;

  const BookingFlowScreen({
    super.key,
    required this.business,
    this.appointmentToReschedule,
  });

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
          _buildProgressBar(bookingState.currentStep),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: _buildStepContent(bookingState.currentStep, business),
          ),
          _buildBottomBar(context, ref, bookingState, business),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= currentStep ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
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

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, BookingState state, Business business) {
    bool canContinue = false;
    if (state.currentStep == 0) canContinue = state.selectedServices.isNotEmpty;
    if (state.currentStep == 1) {
      canContinue = state.selectedDate != null &&
          state.selectedTime != null &&
          state.professionalId != null;
    }
    if (state.currentStep == 2) canContinue = !state.isLoading;

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
                    Text('Total (${state.selectedServices.length} serv.)', style: AppTypography.bodyMedium),
                    Text(
                      NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(state.totalPrice),
                      style: AppTypography.h3.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: canContinue ? () => _handleContinue(context, ref, state, business) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      state.currentStep == 2 ? 'Confirmar Reserva' : 'Continuar',
                      style: AppTypography.titleMedium.copyWith(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue(BuildContext context, WidgetRef ref, BookingState state, Business business) async {
    if (state.currentStep < 2) {
      ref.read(bookingStateProvider.notifier).nextStep();
    } else {
      final auth = ref.read(authStateProvider).value;
      if (auth == null) return;

      final success = await ref.read(bookingStateProvider.notifier).submitBooking(
        userId: auth.id,
        businessId: business.id,
        businessName: business.name,
        rescheduleAppointmentId: appointmentToReschedule?.id,
      );

      if (success && context.mounted) {
        _showSuccessDialog(context, appointmentToReschedule != null);
      } else if (state.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
      }
    }
  }

  void _showSuccessDialog(BuildContext context, bool isReschedule) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Icon(Icons.check_circle, color: AppColors.success, size: 60)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isReschedule ? '¡Reagendado!' : '¡Reserva Exitosa!', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(isReschedule ? 'Tu cita ha sido reprogramada correctamente.' : 'Tu cita ha sido agendada correctamente.', textAlign: TextAlign.center),
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
        if (services.isEmpty) return const Center(child: Text('No hay servicios disponibles.'));
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final isSelected = bookingState.selectedServices.any((s) => s.id == service.id);
            return _ServiceItem(service: service, isSelected: isSelected);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }
}

class _ServiceItem extends ConsumerWidget {
  final Service service;
  final bool isSelected;
  const _ServiceItem({required this.service, required this.isSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        onTap: () => ref.read(bookingStateProvider.notifier).toggleService(service),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(service.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(service.duration, style: AppTypography.bodySmall),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(service.price),
                      style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => ref.read(bookingStateProvider.notifier).toggleService(service),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            data: (team) => _ProfessionalList(team: team, selectedId: bookingState.professionalId),
            loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
            error: (err, __) => Text('Error: $err'),
          ),
          if (bookingState.professionalId != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Fecha', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: bookingState.selectedDate ?? DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(bookingState.selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) => ref.read(bookingStateProvider.notifier).selectDate(selectedDay),
              calendarStyle: const CalendarStyle(selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Horario disponible', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            if (bookingState.selectedDate != null) _TimeGrid(businessId: businessId) else const Text('Selecciona una fecha primero'),
          ] else
            _NoProfessionalPlaceholder(),
        ],
      ),
    );
  }
}

class _ProfessionalList extends ConsumerWidget {
  final List<Map<String, dynamic>> team;
  final String? selectedId;
  const _ProfessionalList({required this.team, required this.selectedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: team.length,
        itemBuilder: (context, index) {
          final member = team[index];
          final memberId = member['userId'] ?? member['id'] ?? '';
          final isSelected = selectedId == memberId;
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
  }
}

class _TimeGrid extends ConsumerWidget {
  final String businessId;
  const _TimeGrid({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingStateProvider);
    final appointmentsAsync = ref.watch(businessAppointmentsProvider((businessId, bookingState.selectedDate!)));
    final teamAsync = ref.watch(businessTeamProvider(businessId));

    return appointmentsAsync.when(
      data: (appointments) {
        final occupiedTimes = appointments
            .where((a) => a.professionalId == bookingState.professionalId && a.status != 'cancelled')
            .map((a) => DateFormat('HH:mm').format(a.dateTime))
            .toSet();

        final team = teamAsync.value ?? [];
        final selectedMember = team.firstWhere((m) => (m['userId'] ?? m['id']) == bookingState.professionalId, orElse: () => {});
        final availableHours = (selectedMember['workingHours'] as List?)?.cast<String>() ?? ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];

        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: availableHours.map((time) {
            final isSelected = bookingState.selectedTime == time;
            final isOccupied = occupiedTimes.contains(time);
            return ChoiceChip(
              label: Text(time, style: TextStyle(color: isOccupied ? Colors.grey : (isSelected ? Colors.white : AppColors.textPrimary))),
              selected: isSelected,
              onSelected: isOccupied ? null : (_) => ref.read(bookingStateProvider.notifier).selectTime(time),
              selectedColor: AppColors.primary,
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Text('Error: $err'),
    );
  }
}

class _NoProfessionalPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(children: [
          Icon(Icons.person_search, size: 64, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          const Text('Selecciona un profesional primero para ver su disponibilidad.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
        ]),
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
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)),
              child: Column(children: [
                Row(children: [const Icon(Icons.storefront, color: AppColors.primary), const SizedBox(width: 12), Text(business.name, style: AppTypography.titleLarge)]),
                const Divider(height: 32),
                _buildRow(Icons.calendar_today, 'Fecha', DateFormat('EEEE, d MMMM', 'es').format(state.selectedDate!)),
                const SizedBox(height: 16),
                _buildRow(Icons.access_time, 'Hora', state.selectedTime!),
                const SizedBox(height: 16),
                _buildRow(Icons.person_outline, 'Profesional', state.professionalName!),
              ]),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Servicios seleccionados', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            ...state.selectedServices.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(s.name, style: AppTypography.bodyMedium),
                Text('\$${s.price.toStringAsFixed(0)}', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ]),
            )),
          ],
        ),
      );
    });
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 20, color: AppColors.textSecondary),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ]),
    ]);
  }
}
