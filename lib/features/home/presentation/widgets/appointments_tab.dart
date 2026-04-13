import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/appointment.dart';
import '../providers/booking_providers.dart';

class AppointmentsTab extends ConsumerStatefulWidget {
  const AppointmentsTab({super.key});

  @override
  ConsumerState<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends ConsumerState<AppointmentsTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Map<DateTime, List<Appointment>> _groupAppointments(List<Appointment> appointments) {
    final Map<DateTime, List<Appointment>> grouped = {};
    for (var appt in appointments) {
      final date = _normalizeDate(appt.dateTime);
      if (grouped[date] == null) grouped[date] = [];
      grouped[date]!.add(appt);
    }
    return grouped;
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + offset,
        1,
      );
      _selectedDate = _focusedDay;
    });
  }

  Widget _buildChevronButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(userAppointmentsProvider);

    return SafeArea(
      child: appointmentsAsync.when(
        data: (appointments) {
          final groupedAppointments = _groupAppointments(appointments);
          final selectedAppointments = groupedAppointments[_normalizeDate(_selectedDate)] ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis Citas',
                        style: AppTypography.h2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Revisa tu agenda y tus próximas reservas',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildCalendarCard(context, groupedAppointments),
                      const SizedBox(height: AppSpacing.xl),
                      _buildScheduleSection(selectedAppointments),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context, Map<DateTime, List<Appointment>> grouped) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(context),
          const SizedBox(height: AppSpacing.md),
          TableCalendar<Appointment>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => _normalizeDate(day) == _normalizeDate(_selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _selectedDate = DateTime(focusedDay.year, focusedDay.month, 1);
              });
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
              weekendStyle: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            calendarStyle: CalendarStyle(
              markersMaxCount: 1,
              markerDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.rectangle, // FIXED: Explicit shape to allow borderRadius
                borderRadius: BorderRadius.circular(16),
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.rectangle, // FIXED: Explicit shape to allow borderRadius
                borderRadius: BorderRadius.circular(16),
              ),
              outsideDaysVisible: false,
              defaultTextStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              todayTextStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              selectedTextStyle: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              cellPadding: const EdgeInsets.only(bottom: 6),
            ),
            calendarBuilders: CalendarBuilders<Appointment>(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  bottom: 6,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            eventLoader: (day) => grouped[_normalizeDate(day)] ?? [],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM yyyy', 'es').format(_focusedDay),
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Selecciona un día para ver tus citas',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildChevronButton(Icons.chevron_left, () => _changeMonth(-1)),
            const SizedBox(width: AppSpacing.sm),
            _buildChevronButton(Icons.chevron_right, () => _changeMonth(1)),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleSection(List<Appointment> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Citas del ${DateFormat('EEEE, d', 'es').format(_selectedDate)}',
              style: AppTypography.titleMedium,
            ),
            if (appointments.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${appointments.length} citas',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (appointments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'No tienes citas agendadas para este día. Selecciona otra fecha en el calendario.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          Column(
            children: appointments
                .map(
                  (appointment) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              DateFormat('HH:mm').format(appointment.dateTime),
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.businessName,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                appointment.serviceNames.join(', '),
                                style: AppTypography.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Con: ${appointment.professionalName}',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(appointment.status),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'confirmed':
        color = const Color(0xFF10B981);
        text = 'Confirmada';
        break;
      case 'cancelled':
        color = const Color(0xFFEF4444);
        text = 'Cancelada';
        break;
      case 'completed':
        color = Colors.blue;
        text = 'Completada';
        break;
      default:
        color = const Color(0xFFF97316);
        text = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
