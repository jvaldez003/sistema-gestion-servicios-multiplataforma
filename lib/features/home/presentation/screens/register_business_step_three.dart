import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/business_registration_provider.dart';
import 'home_screen.dart';

class RegisterBusinessStepThree extends ConsumerStatefulWidget {
  const RegisterBusinessStepThree({super.key});

  @override
  ConsumerState<RegisterBusinessStepThree> createState() =>
      _RegisterBusinessStepThreeState();
}

class _RegisterBusinessStepThreeState
    extends ConsumerState<RegisterBusinessStepThree> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool hasPhysicalLocation = true;

  @override
  void initState() {
    super.initState();
    final state = ref.read(businessRegistrationProvider);
    _addressController.text = state.address;
    _cityController.text = state.city;
    _descriptionController.text = state.description;
    hasPhysicalLocation = state.hasPhysicalLocation;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(businessRegistrationProvider);

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
              _buildProgressIndicator(3),
              const SizedBox(height: AppSpacing.xl),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Ubicación y detalles',
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Completa los últimos detalles',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  Checkbox(
                    value: hasPhysicalLocation,
                    onChanged: (val) =>
                        setState(() => hasPhysicalLocation = val ?? true),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Text(
                    'Tengo un local físico',
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              if (hasPhysicalLocation) ...[
                _buildField(
                    'Dirección *', 'Calle 123 #45-67', _addressController),
                const SizedBox(height: AppSpacing.lg),
                _buildField(
                    'Ciudad *', 'Bogotá, Medellín, Cali...', _cityController),
                const SizedBox(height: AppSpacing.lg),
              ],

              _buildField(
                'Descripción de tu negocio *',
                'Cuéntanos qué servicios ofreces y qué hace especial a tu negocio...',
                _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Benefits Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Por qué unirte a FlowServ?',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildBenefitItem('Gestiona citas de forma automática'),
                    _buildBenefitItem('Llega a más clientes en tu zona'),
                    _buildBenefitItem('Administra tu equipo fácilmente'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              ElevatedButton(
                onPressed: registrationState.isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: registrationState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Finalizar registro',
                        style: AppTypography.titleMedium
                            .copyWith(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() async {
    if (_descriptionController.text.isNotEmpty &&
        (!hasPhysicalLocation ||
            (_addressController.text.isNotEmpty &&
                _cityController.text.isNotEmpty))) {
      ref.read(businessRegistrationProvider.notifier).updateLocationDetails(
            hasPhysicalLocation: hasPhysicalLocation,
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
            description: _descriptionController.text.trim(),
          );

      await ref.read(businessRegistrationProvider.notifier).submit();

      final currentState = ref.read(businessRegistrationProvider);

      if (mounted) {
        if (currentState.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(currentState.errorMessage!),
                backgroundColor: AppColors.error),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Negocio registrado con éxito!')),
          );
          // Navigate to Home Screen and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor completa los campos obligatorios')),
      );
    }
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleMedium.copyWith(fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
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
            _buildStepCircle(2, true, isCompleted: true),
            _buildStepLine(true),
            _buildStepCircle(3, true),
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

