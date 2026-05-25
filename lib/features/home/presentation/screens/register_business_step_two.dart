import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/business_registration_provider.dart';
import 'register_business_step_three.dart';

class RegisterBusinessStepTwo extends ConsumerStatefulWidget {
  const RegisterBusinessStepTwo({super.key});

  @override
  ConsumerState<RegisterBusinessStepTwo> createState() =>
      _RegisterBusinessStepTwoState();
}

class _RegisterBusinessStepTwoState
    extends ConsumerState<RegisterBusinessStepTwo> {
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? selectedEmployeeCount;

  final List<String> employeeOptions = [
    'Solo yo',
    '2 - 5 empleados',
    '6 - 15 empleados',
    'Más de 15 empleados',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(businessRegistrationProvider);
    _ownerNameController.text = state.ownerName;
    _emailController.text = state.email;
    _phoneController.text = state.phone;
    selectedEmployeeCount =
        state.employeeCount.isEmpty ? null : state.employeeCount;
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
              Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              _buildProgressIndicator(2),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.group_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Datos de contacto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '¿Cómo podemos contactarte?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildField('Nombre del propietario *', 'Tu nombre completo',
                  _ownerNameController),
              const SizedBox(height: AppSpacing.lg),
              _buildField(
                  'Correo electrónico *', 'tu@email.com', _emailController,
                  icon: Icons.email_outlined),
              const SizedBox(height: AppSpacing.lg),
              _buildField(
                  'Teléfono / WhatsApp *', '300 123 4567', _phoneController,
                  icon: Icons.phone_outlined),
              const SizedBox(height: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Número de empleados (opcional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedEmployeeCount,
                        hint: const Text('Selecciona una opción'),
                        isExpanded: true,
                        items: employeeOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() => selectedEmployeeCount = newValue);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
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
                      Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() {
    if (_ownerNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty) {
      ref.read(businessRegistrationProvider.notifier).updateContactInfo(
            ownerName: _ownerNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            employeeCount: selectedEmployeeCount,
          );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const RegisterBusinessStepThree()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor completa los campos obligatorios')),
      );
    }
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller,
      {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textSecondary, size: 20)
                : null,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(int step) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepCircle(1, true, isCompleted: true),
            _buildStepLine(true),
            _buildStepCircle(2, true),
            _buildStepLine(false),
            _buildStepCircle(3, false),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Paso $step de 3',
          style:
              Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStepCircle(int number, bool active, {bool isCompleted = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
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

