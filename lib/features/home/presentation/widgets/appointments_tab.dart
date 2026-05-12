import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/appointment.dart';
import '../providers/booking_providers.dart';
import '../providers/booking_notifier.dart';

class AppointmentsTab extends ConsumerStatefulWidget {
  const AppointmentsTab({super.key});

  @override
  ConsumerState<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends ConsumerState<AppointmentsTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool _isProfessionalMode = false;

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

  @override
  Widget build(BuildContext context) {
    final isProfessional = ref.watch(isProfessionalProvider);
    final appointmentsAsync = _isProfessionalMode 
        ? ref.watch(professionalAppointmentsProvider)
        : ref.watch(userAppointmentsProvider);

    return SafeArea(
      child: appointmentsAsync.when(
        data: (appointments) {
          final groupedAppointments = _groupAppointments(appointments);
          final selectedAppointments = groupedAppointments[_normalizeDate(_selectedDate)] ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_isProfessionalMode ? 'Mi Agenda' : 'Mis Citas', style: AppTypography.h2),
                          if (isProfessional)
                            _buildModeToggle(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _isProfessionalMode 
                            ? 'Gestiona tus citas de hoy y próximos servicios'
                            : 'Revisa tu agenda y tus próximas reservas',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: _buildCalendarCard(context, groupedAppointments),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: _buildScheduleHeader(selectedAppointments.length),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: selectedAppointments.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildAppointmentCard(selectedAppointments[index]),
                          childCount: selectedAppointments.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.person_outline,
            label: 'Cliente',
            isSelected: !_isProfessionalMode,
            onTap: () => setState(() => _isProfessionalMode = false),
          ),
          _buildToggleButton(
            icon: Icons.work_outline,
            label: 'Pro',
            isSelected: _isProfessionalMode,
            onTap: () => setState(() => _isProfessionalMode = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context, Map<DateTime, List<Appointment>> grouped) {
    return Column(
      children: [
        _buildCalendarHeader(context),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 60, // Total days to show
            itemBuilder: (context, index) {
              final date = DateTime.now().subtract(const Duration(days: 15)).add(Duration(days: index));
              final isSelected = _normalizeDate(date) == _normalizeDate(_selectedDate);
              final isToday = _normalizeDate(date) == _normalizeDate(DateTime.now());
              final hasEvents = grouped[_normalizeDate(date)]?.isNotEmpty ?? false;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                      _focusedDay = date;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.black.withOpacity(0.04),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        if (hasEvents && !isSelected) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        if (isToday && !isSelected) ...[
                           const SizedBox(height: 2),
                           Text(
                             'Hoy',
                             style: TextStyle(
                               color: AppColors.primary,
                               fontSize: 8,
                               fontWeight: FontWeight.w900,
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
      ],
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
                DateFormat('MMMM', 'es').format(_focusedDay).toUpperCase(),
                style: AppTypography.bodySmall.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Text(
                DateFormat('yyyy', 'es').format(_focusedDay),
                style: AppTypography.h3.copyWith(
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              _buildIconButton(Icons.calendar_month_rounded, () => _showFullCalendarPicker(context)),
              const SizedBox(width: 4),
              _buildIconButton(Icons.chevron_left_rounded, () => _changeMonth(-1)),
              const SizedBox(width: 4),
              _buildIconButton(Icons.chevron_right_rounded, () => _changeMonth(1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }

  void _showFullCalendarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
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
                        'Seleccionar Fecha',
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
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        locale: 'es_ES',
                        selectedDayPredicate: (day) => _normalizeDate(day) == _normalizeDate(_selectedDate),
                        onDaySelected: (selectedDay, focusedDay) {
                          setModalState(() {
                             _focusedDay = focusedDay;
                          });
                          setState(() {
                            _selectedDate = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          Navigator.pop(context);
                        },
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                          rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          selectedDecoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
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

  Widget _buildScheduleHeader(int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Agenda para hoy',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary.withOpacity(0.3), size: 48),
          const SizedBox(height: 16),
          Text(
            'Sin citas para este día',
            style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '¿Por qué no agendas algo nuevo hoy?',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('HH:mm').format(appointment.dateTime),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  appointment.dateTime.hour < 12 ? 'AM' : 'PM',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
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
                  _isProfessionalMode ? 'Cita con cliente' : appointment.businessName,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.bolt, size: 12, color: AppColors.primaryLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        appointment.serviceNames.join(', '),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _isProfessionalMode ? Icons.person_outline : Icons.person_pin_circle_outlined, 
                      size: 12, 
                      color: AppColors.textSecondary
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isProfessionalMode ? 'Cliente ID: ${appointment.userId.substring(0, 5)}...' : appointment.professionalName,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusBadge(appointment.status),
              if (appointment.status == 'pending' || appointment.status == 'confirmed') ...[
                const SizedBox(height: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'cancel') {
                      _confirmCancellation(context, appointment.id!);
                    } else if (value == 'reschedule') {
                      _rescheduleAppointment(context, appointment);
                    } else if (value == 'complete') {
                      _completeAppointment(context, appointment.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    if (_isProfessionalMode)
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Completar'),
                          ],
                        ),
                      ),
                    if (!_isProfessionalMode)
                      const PopupMenuItem(
                        value: 'reschedule',
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Reagendar'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Cancelar cita', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCancellation(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar cita?'),
        content: const Text('¿Estás seguro de que deseas cancelar esta cita? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, mantener'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              final success = await ref.read(bookingStateProvider.notifier).cancelAppointment(appointmentId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cita cancelada correctamente'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(BuildContext context, Appointment appointment) {
    ref.read(bookingStateProvider.notifier).initializeForRescheduling(appointment);
    context.push('/business/${appointment.businessId}/booking', extra: {
      'appointment': appointment,
    });
  }

  void _completeAppointment(BuildContext context, String appointmentId) async {
    final success = await ref.read(bookingStateProvider.notifier).updateAppointmentStatus(appointmentId, 'completed');
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita completada correctamente'), backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case 'confirmed':
        color = const Color(0xFF10B981);
        text = 'Confirmada';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        color = const Color(0xFFEF4444);
        text = 'Cancelada';
        icon = Icons.cancel_outlined;
        break;
      case 'completed':
        color = AppColors.primary;
        text = 'Finalizada';
        icon = Icons.done_all_rounded;
        break;
      default:
        color = const Color(0xFFF97316);
        text = 'Pendiente';
        icon = Icons.access_time_rounded;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
