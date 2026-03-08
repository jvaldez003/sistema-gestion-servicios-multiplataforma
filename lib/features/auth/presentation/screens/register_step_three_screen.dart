import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_notifier.dart';
import '../providers/registration_provider.dart';

class RegisterStepThreeScreen extends ConsumerStatefulWidget {
  const RegisterStepThreeScreen({super.key});

  @override
  ConsumerState<RegisterStepThreeScreen> createState() =>
      _RegisterStepThreeScreenState();
}

class _RegisterStepThreeScreenState
    extends ConsumerState<RegisterStepThreeScreen> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  void _handleRegistration() async {
    final registrationData = ref.read(registrationProvider);

    await ref.read(authNotifierProvider.notifier).signUp(
          registrationData.email,
          registrationData.password,
          name: registrationData.name,
          phoneNumber: registrationData.phoneNumber,
        );

    final authState = ref.read(authNotifierProvider);
    if (authState.status == AuthStatus.authenticated && mounted) {
      // Reset registration data
      ref.read(registrationProvider.notifier).reset();

      // Navigate to home or show success
      // El AuthNotifier debería manejar la redirección si usas un listener en main.dart
      // Pero por ahora, podemos cerrar los pasos de registro
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (authState.status == AuthStatus.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? 'Error al crear la cuenta'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrationData = ref.watch(registrationProvider);
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crear cuenta',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Stepper Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle(1, false, isCompleted: true),
                  _buildStepLine(isCompleted: true),
                  _buildStepCircle(2, false, isCompleted: true),
                  _buildStepLine(isCompleted: true),
                  _buildStepCircle(3, true),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Paso 3 de 3 · Finalizar',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 50,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Title and Description
              Text(
                '¡Casi listo!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Solo necesitamos tu confirmación para completar el registro',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen de tu cuenta',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildSummaryRow('Nombre:', registrationData.name),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSummaryRow('Email:', registrationData.email),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSummaryRow('Teléfono:', registrationData.phoneNumber),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Checkboxes
              _buildCheckboxRow(
                value: _acceptedTerms,
                onChanged: (val) {
                  setState(() => _acceptedTerms = val ?? false);
                },
                text: 'Acepto los ',
                linkText: 'Términos y Condiciones',
                suffixText: ' de FlowServ',
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildCheckboxRow(
                value: _acceptedPrivacy,
                onChanged: (val) {
                  setState(() => _acceptedPrivacy = val ?? false);
                },
                text: 'Acepto la ',
                linkText: 'Política de Privacidad',
                suffixText: ' y el tratamiento de mis datos',
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Submit Button
              PrimaryButton(
                text: 'Crear mi cuenta',
                isLoading: isLoading,
                onPressed: (_acceptedTerms && _acceptedPrivacy && !isLoading)
                    ? _handleRegistration
                    : null,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(int step, bool isActive, {bool isCompleted = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: (isActive || isCompleted) ? AppColors.primary : AppColors.border,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine({bool isCompleted = false}) {
    return Container(
      width: 40,
      height: 3,
      color: isCompleted ? AppColors.primary : AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    required String linkText,
    required String suffixText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
              children: [
                TextSpan(
                  text: linkText,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: suffixText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
