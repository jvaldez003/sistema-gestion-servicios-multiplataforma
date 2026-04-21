import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/business_registration_provider.dart';
import 'register_business_step_two.dart';

class RegisterBusinessStepOne extends ConsumerStatefulWidget {
  const RegisterBusinessStepOne({super.key});

  @override
  ConsumerState<RegisterBusinessStepOne> createState() =>
      _RegisterBusinessStepOneState();
}

class _RegisterBusinessStepOneState
    extends ConsumerState<RegisterBusinessStepOne> {
  final _nameController = TextEditingController();
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Barbería', 'icon': '💈'},
    {'name': 'Estética', 'icon': '💅'},
    {'name': 'Lavadero de autos', 'icon': '🚗'},
    {'name': 'Consultorio médico', 'icon': '🏥'},
    {'name': 'Spa', 'icon': '🧖‍♀️'},
    {'name': 'Gimnasio', 'icon': '💪'},
    {'name': 'Salón de belleza', 'icon': '✨'},
    {'name': 'Odontología', 'icon': '🦷'},
    {'name': 'Veterinaria', 'icon': '🐾'},
    {'name': 'Fotografía', 'icon': '📷'},
    {'name': 'Masajes', 'icon': '💆‍♀️'},
    {'name': 'Otro', 'icon': '🏢'},
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(businessRegistrationProvider);
    _nameController.text = state.name;
    selectedCategory = state.category.isEmpty ? null : state.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Registra tu negocio',
          style:
              AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(1),
              const SizedBox(height: AppSpacing.xl),

              // Icon Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Información del negocio',
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Cuéntanos sobre tu negocio',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Business Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Nombre del negocio ',
                      style: AppTypography.titleMedium.copyWith(fontSize: 14),
                      children: const [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Barbería El Clásico',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Categoría ',
                      style: AppTypography.titleMedium.copyWith(fontSize: 14),
                      children: const [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = selectedCategory == cat['name'];

                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedCategory = cat['name']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFE5E7EB),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(cat['icon'],
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 8),
                              Text(
                                cat['name'],
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Continue Button
              ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Continuar',
                  style:
                      AppTypography.titleMedium.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() {
    if (_nameController.text.isNotEmpty && selectedCategory != null) {
      ref.read(businessRegistrationProvider.notifier).updateBasicInfo(
            name: _nameController.text.trim(),
            category: selectedCategory,
          );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const RegisterBusinessStepTwo()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor completa los campos obligatorios')),
      );
    }
  }

  Widget _buildProgressIndicator(int step) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepCircle(1, step >= 1),
            _buildStepLine(step >= 2),
            _buildStepCircle(2, step >= 2),
            _buildStepLine(step >= 3),
            _buildStepCircle(3, step >= 3),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Paso $step de 3',
          style:
              AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStepCircle(int number, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool active) {
    return Container(
      width: 60,
      height: 2,
      color: active ? AppColors.primary : const Color(0xFFE5E7EB),
    );
  }
}

