import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/business.dart';
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

  final List<String> _allPossibleHours = [
    '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
    '19:00', '20:00', '21:00'
  ];

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(professionalBusinessesProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mi Horario de Trabajo'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: businessesAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return const Center(child: Text('No eres profesional en ningún negocio.'));
          }

          if (_selectedBusiness == null && businesses.isNotEmpty) {
            // Delay selection to avoid build-time state changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _onBusinessSelected(businesses.first, user?.id ?? '');
              }
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (businesses.length > 1)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selecciona el negocio', style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Business>(
                            value: _selectedBusiness,
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
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                        return _buildHourChip(hour, isSelected);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Text('Horas personalizadas', style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ..._workingHours
                            .where((h) => !_allPossibleHours.contains(h))
                            .map((h) => _buildHourChip(h, true)),
                        InkWell(
                          onTap: _pickCustomTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                  style: AppTypography.bodySmall.copyWith(
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
                  onPressed: _selectedBusiness != null && !_isSaving ? () => _saveHours(user?.id ?? '') : null,
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

  Widget _buildHourChip(String hour, bool isSelected) {
    return InkWell(
      onTap: () => _toggleHour(hour),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(minWidth: 80),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Center(
          child: Text(
            hour,
            style: AppTypography.bodyMedium.copyWith(
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
      final timeString = "$hour:$minute";
      _toggleHour(timeString);
    }
  }

  void _onBusinessSelected(Business business, String userId) async {
    setState(() {
      _selectedBusiness = business;
      _workingHours = [];
    });

    // Fetch current hours from Firebase
    final teamRepo = FirebaseTeamRepository();
    final teamStream = teamRepo.getTeamStream(business.id);
    final team = await teamStream.first;
    final member = team.firstWhere((m) => (m['userId'] ?? m['id']) == userId, orElse: () => {});
    
    if (mounted) {
      setState(() {
        _workingHours = (member['workingHours'] as List?)?.cast<String>() ?? [];
      });
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
    if (_selectedBusiness == null) return;
    
    setState(() => _isSaving = true);
    try {
      final teamRepo = FirebaseTeamRepository();
      await teamRepo.updateTeamMember(_selectedBusiness!.id, userId, {
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
}
