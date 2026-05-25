import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/business.dart';
import '../../domain/models/appointment.dart';
import '../providers/booking_providers.dart';
import '../../data/repositories/firebase_team_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfessionalScheduleScreen extends ConsumerStatefulWidget {
  const ProfessionalScheduleScreen({super.key});

  @override
  ConsumerState<ProfessionalScheduleScreen> createState() => _ProfessionalScheduleScreenState();
}

class _ProfessionalScheduleScreenState extends ConsumerState<ProfessionalScheduleScreen> {
  Business? _selectedBusiness;
  List<String> _workingHours = [];
  bool _isSaving = false;
  bool _isLoadingMember = false;
  String? _teamMemberId;

  final List<String> _allPossibleHours = [
    '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
    '19:00', '20:00', '21:00'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final businessesAsync = ref.watch(professionalBusinessesProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Horario de Trabajo'),
      ),
      body: businessesAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return const Center(child: Text('No eres profesional en ningún negocio.'));
          }

          if (_selectedBusiness == null && businesses.isNotEmpty && (user?.id ?? '').isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _onBusinessSelected(businesses.first, user!.id);
              }
            });
          }

          final dropdownValue = _selectedBusiness == null
              ? null
              : businesses.where((b) => b.id == _selectedBusiness!.id).firstOrNull;

          final todayApptsAsync = ref.watch(memberScheduleProvider(user?.id ?? ''));
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayEnd = todayStart.add(const Duration(days: 1));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              todayApptsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (appts) {
                  final todayAppts = appts
                      .where((a) => a.status != 'cancelled' && a.dateTime.isAfter(todayStart) && a.dateTime.isBefore(todayEnd))
                      .toList()
                    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Citas de Hoy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${todayAppts.length}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (todayAppts.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).dividerColor),
                            ),
                            child: const Text('Sin citas programadas para hoy', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          )
                        else
                          ...todayAppts.map((a) => _buildTodayAppointmentCard(context, a, isDark: isDark)),
                        const Divider(height: 24),
                      ],
                    ),
                  );
                },
              ),
              if (businesses.length > 1)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selecciona el negocio', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Business>(
                            value: dropdownValue,
                            isExpanded: true,
                            items: businesses.map((b) => DropdownMenuItem(
                              value: b,
                              child: Text(b.name),
                            )).toList(),
                            onChanged: (b) {
                              if (b != null) _onBusinessSelected(b, user?.id ?? '');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Selecciona tus horas disponibles para ${_selectedBusiness?.name ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _allPossibleHours.length,
                      itemBuilder: (context, index) {
                        final hour = _allPossibleHours[index];
                        final isSelected = _workingHours.contains(hour);
                        return _buildHourChip(context, hour, isSelected, isDark: isDark);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Text('Horas personalizadas', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ..._workingHours
                            .where((h) => !_allPossibleHours.contains(h))
                            .map((h) => _buildHourChip(context, h, true, isDark: isDark)),
                        InkWell(
                          onTap: _pickCustomTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add, size: 18, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Añadir hora',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ElevatedButton(
                  onPressed: _selectedBusiness != null && !_isSaving && !_isLoadingMember && (user?.id ?? '').isNotEmpty
                      ? () => _saveHours(user!.id)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar Horario', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHourChip(BuildContext context, String hour, bool isSelected, {required bool isDark}) {
    return InkWell(
      onTap: () => _toggleHour(hour),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(minWidth: 80),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            hour,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }

  void _pickCustomTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      _toggleHour('$hour:$minute');
    }
  }

  void _onBusinessSelected(Business business, String userId) async {
    if (userId.isEmpty) return;
    setState(() {
      _selectedBusiness = business;
      _workingHours = [];
      _isLoadingMember = true;
      _teamMemberId = null;
    });

    try {
      final teamRepo = FirebaseTeamRepository();
      final team = await teamRepo.getTeamStream(business.id).first;
      final member = team.firstWhere((m) => (m['userId'] ?? m['id']) == userId, orElse: () => {});
      if (mounted) {
        setState(() {
          _teamMemberId = member.isNotEmpty ? (member['id'] as String?) : null;
          _workingHours = (member['workingHours'] as List?)?.cast<String>() ?? [];
          _isLoadingMember = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMember = false);
    }
  }

  void _toggleHour(String hour) {
    setState(() {
      if (_workingHours.contains(hour)) {
        _workingHours.remove(hour);
      } else {
        _workingHours.add(hour);
        _workingHours.sort();
      }
    });
  }

  void _saveHours(String userId) async {
    if (_selectedBusiness == null || userId.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final teamRepo = FirebaseTeamRepository();
      final docId = _teamMemberId ?? userId;
      await teamRepo.updateTeamMember(_selectedBusiness!.id, docId, {
        'workingHours': _workingHours,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horario actualizado correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTodayAppointmentCard(BuildContext context, Appointment appt, {required bool isDark}) {
    final statusColor = appt.status == 'confirmed' ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final statusLabel = appt.status == 'confirmed' ? 'Confirmada' : 'Pendiente';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              DateFormat('HH:mm').format(appt.dateTime),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.serviceNames.join(', '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(appt.businessName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
          ),
        ],
      ),
    );
  }
}
