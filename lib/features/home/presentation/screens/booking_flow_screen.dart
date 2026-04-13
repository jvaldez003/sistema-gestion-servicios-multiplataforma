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
import '../providers/business_details_providers.dart';
import '../providers/booking_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class BookingFlowScreen extends ConsumerWidget {
  final Business? business;
  final String? businessId;

  const BookingFlowScreen({
    super.key,
    this.business,
    this.businessId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = business?.id ?? businessId!;
    final businessAsync = ref.watch(businessStreamProvider(id));

    return businessAsync.when(
      data: (businessData) {
        if (businessData == null) {
          return const Scaffold(
            body: Center(child: Text('Negocio no encontrado')),
          );
        }

        final bookingState = ref.watch(bookingStateProvider);

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookingState.currentStep == 0
                      ? 'Seleccionar Servicios'
                      : bookingState.currentStep == 1
                          ? 'Elegir Horario'
                          : 'Confirmar Reserva',
                  style:
                      AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  'Paso ${bookingState.currentStep + 1} de 3',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
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
            centerTitle: false,
          ),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: Row(
                  children: List.generate(3, (index) {
                    final isActive = index <= bookingState.currentStep;
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.border.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: _buildStepContent(bookingState.currentStep, businessData),
              ),
              _buildBottomBar(context, ref, bookingState, businessData),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
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
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRECIO TOTAL',
                          style: AppTypography.bodySmall.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${state.totalPrice.toStringAsFixed(0)}',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.selectedServices.length} servicios',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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
                disabledBackgroundColor: AppColors.border.withOpacity(0.5),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                state.currentStep == 2 ? 'Reservar Ahora' : 'Confirmar y Continuar',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
      final authData = ref.read(authStateProvider);
      final auth = authData.value;
      if (auth == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, inicia sesión para continuar')),
          );
        }
        return;
      }

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Center(
                child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 80),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('¡Reserva Exitosa!', style: AppTypography.h3.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const Text(
                    'Tu cita ha sido agendada. Te esperamos pronto.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // dialog
                      Navigator.of(context).pop(); // booking screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Entendido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
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

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => ref.read(bookingStateProvider.notifier).toggleService(service),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.content_cut_rounded,
                            color: isSelected ? Colors.white : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                service.duration,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${service.price.toStringAsFixed(0)}',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                              color: isSelected ? AppColors.primary : AppColors.border,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

class _SchedulingStep extends ConsumerStatefulWidget {
  final String businessId;

  const _SchedulingStep({required this.businessId});

  @override
  ConsumerState<_SchedulingStep> createState() => _SchedulingStepState();
}

class _SchedulingStepState extends ConsumerState<_SchedulingStep> {
  DateTime _focusedDay = DateTime.now();

  void _changeMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + offset,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingStateProvider);
    final teamAsync = ref.watch(businessTeamProvider(widget.businessId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Profesional', null),
          const SizedBox(height: AppSpacing.md),
          teamAsync.when(
            data: (team) {
              return SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: team.length,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, index) {
                    final member = team[index];
                    final memberId = member['userId'] ?? member['id'] ?? '';
                    final isSelected = bookingState.professionalId == memberId;
                    return GestureDetector(
                      onTap: () => ref.read(bookingStateProvider.notifier).selectProfessional(memberId, member['name']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: isSelected ? Colors.white : AppColors.primary.withOpacity(0.1),
                                child: Text(
                                  member['name'][0].toUpperCase(),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                member['name'],
                                style: AppTypography.bodySmall.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
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
            loading: () => const SizedBox(height: 110, child: Center(child: CircularProgressIndicator())),
            error: (err, __) => Text('Error: $err'),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader(
            'Fecha',
            DateFormat('MMMM yyyy', 'es').format(_focusedDay).toUpperCase(),
            action: IconButton(
              onPressed: () => _showFullCalendarPicker(context, ref),
              icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 30, // Next 30 days
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = isSameDay(bookingState.selectedDate, date);
                final isToday = isSameDay(DateTime.now(), date);

                return Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 8, top: 2),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _focusedDay = date;
                      });
                      ref.read(bookingStateProvider.notifier).selectDate(date);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 65,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                            blurRadius: isSelected ? 12 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE', 'es').format(date).toUpperCase(),
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textSecondary.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          if (isToday && !isSelected) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Horario',
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          if (bookingState.selectedDate != null)
            Consumer(
              builder: (context, ref, child) {
                final appointmentsAsync = ref.watch(businessAppointmentsProvider((widget.businessId, bookingState.selectedDate!)));
                
                return appointmentsAsync.when(
                  data: (appointments) {
                    final occupiedTimes = appointments
                        .where((a) => a.professionalId == bookingState.professionalId && a.status != 'cancelled')
                        .map((a) => DateFormat('HH:mm').format(a.dateTime))
                        .toSet();

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00'].map((time) {
                        final isSelected = bookingState.selectedTime == time;
                        final isOccupied = occupiedTimes.contains(time);
                        
                        return InkWell(
                          onTap: isOccupied ? null : () => ref.read(bookingStateProvider.notifier).selectTime(time),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: isOccupied 
                                ? const Color(0xFFF1F5F9) 
                                : (isSelected ? AppColors.primary : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ] : null,
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                color: isOccupied 
                                  ? const Color(0xFF94A3B8) 
                                  : (isSelected ? Colors.white : AppColors.textPrimary),
                                fontWeight: FontWeight.bold,
                                decoration: isOccupied ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
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
            _buildEmptyTimePlaceholder(),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? subtitle, {Widget? action}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  void _showFullCalendarPicker(BuildContext context, WidgetRef ref) {
    final bookingState = ref.read(bookingStateProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Elegir Fecha',
                        style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 90)),
                        focusedDay: _focusedDay,
                        locale: 'es_ES',
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        selectedDayPredicate: (day) => isSameDay(bookingState.selectedDate, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setModalState(() {
                             _focusedDay = focusedDay;
                          });
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                          ref.read(bookingStateProvider.notifier).selectDate(selectedDay);
                          Navigator.pop(context);
                        },
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
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

  Widget _buildEmptyTimePlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Icon(Icons.touch_app_outlined, color: AppColors.textSecondary.withOpacity(0.3), size: 40),
          const SizedBox(height: 12),
          Text(
            'Selecciona una fecha',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          ),
          Text(
            'Para ver los horarios disponibles',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM', 'es').format(_focusedDay).toUpperCase(),
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        Row(
          children: [
            _buildNavButton(Icons.chevron_left_rounded, () => _changeMonth(-1)),
            const SizedBox(width: 8),
            _buildNavButton(Icons.chevron_right_rounded, () => _changeMonth(1)),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
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
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                   Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.storefront_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Text(business.name, style: AppTypography.h3.copyWith(fontWeight: FontWeight.w900))),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(height: 1),
                  ),
                  _buildSummaryRow(Icons.calendar_today_rounded, 'Fecha', DateFormat('EEEE, d MMMM', 'es').format(state.selectedDate!)),
                  const SizedBox(height: 20),
                  _buildSummaryRow(Icons.access_time_rounded, 'Hora', state.selectedTime!),
                  const SizedBox(height: 20),
                  _buildSummaryRow(Icons.person_pin_rounded, 'Profesional', state.professionalName!),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Resumen de Servicios', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            ...state.selectedServices.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border.withOpacity(0.3))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text('\$${s.price.toStringAsFixed(0)}', style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
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
        Icon(icon, size: 22, color: AppColors.textSecondary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }
}
