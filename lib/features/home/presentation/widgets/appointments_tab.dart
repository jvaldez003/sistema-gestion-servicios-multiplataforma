import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  // El calendario es de solo lectura. Las citas deben venir de datos reales,
  // no se generan ni se crean aquí en el widget.
  final Map<DateTime, List<Appointment>> _appointments = {};

  // Devuelve las citas que corresponden a la fecha actualmente seleccionada.
  List<Appointment> get _selectedAppointments {
    return _appointments[_normalizeDate(_selectedDate)] ?? [];
  }

  // TableCalendar usa este cargador de eventos para marcar fechas con citas.
  List<Appointment> _getEventsForDay(DateTime day) {
    return _appointments[_normalizeDate(day)] ?? [];
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _changeMonth(int offset) {
    setState(() {
      // Cambia el mes mostrado en el calendario cuando el usuario toca los chevrons.
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + offset,
        1,
      );
      _selectedDate = _focusedDay;
    });
  }

  Widget _buildChevronButton(IconData icon, VoidCallback onTap) {
    // Botón de navegación para mover el calendario un mes atrás o adelante.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construye la pestaña completa de Mis Citas,
    // incluyendo el calendario y el listado de citas del día seleccionado.
    return SafeArea(
      child: CustomScrollView(
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
                  _buildCalendarCard(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildScheduleSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              markerDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
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
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            eventLoader: _getEventsForDay,
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

  Widget _buildScheduleSection() {
    final appointments = _selectedAppointments;
    // Muestra la sección de horario y detalles de las citas para el día seleccionado.
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
                  color: AppColors.primary.withValues(alpha: 0.12),
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
                          color: Colors.black.withValues(alpha: 0.03),
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
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              appointment.time,
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
                                appointment.service,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                appointment.location,
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class Appointment {
  final String time;
  final String service;
  final String location;

  Appointment({
    required this.time,
    required this.service,
    required this.location,
  });
}
