import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_notifier.dart';
import '../providers/registration_provider.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_shared_widgets.dart';

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
      if (authState.user != null) {
        await ref.read(userRepositoryProvider).updateUserProfile(
          authState.user!.id,
          name: registrationData.name,
          phoneNumber: registrationData.phoneNumber,
        );
      }
      ref.read(registrationProvider.notifier).reset();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AuthStepIndicator(current: 3),
            const SizedBox(height: AppSpacing.xl),

            // ── Check icon ────────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.positiveGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.positiveGreen,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              '¡Casi listo!',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Solo necesitamos tu confirmación para completar el registro',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Summary card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: isDark
                    ? Border.all(color: AppColors.borderDark)
                    : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de tu cuenta',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  _SummaryRow(label: 'Nombre', value: registrationData.name),
                  const SizedBox(height: AppSpacing.sm),
                  _SummaryRow(label: 'Email', value: registrationData.email),
                  const SizedBox(height: AppSpacing.sm),
                  _SummaryRow(
                    label: 'Teléfono',
                    value: registrationData.phoneNumber,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Checkboxes ────────────────────────────────────────────
            _CheckboxRow(
              value: _acceptedTerms,
              onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
              text: 'Acepto los ',
              linkText: 'Términos y Condiciones',
              suffixText: ' de FlowServ',
            ),
            const SizedBox(height: AppSpacing.sm),
            _CheckboxRow(
              value: _acceptedPrivacy,
              onChanged: (val) =>
                  setState(() => _acceptedPrivacy = val ?? false),
              text: 'Acepto la ',
              linkText: 'Política de Privacidad',
              suffixText: ' y el tratamiento de mis datos',
            ),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              label: 'Crear mi cuenta',
              isLoading: isLoading,
              onPressed: (_acceptedTerms && _acceptedPrivacy && !isLoading)
                  ? _handleRegistration
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ── Local helpers ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
        ),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;
  final String linkText;
  final String suffixText;

  const _CheckboxRow({
    required this.value,
    required this.onChanged,
    required this.text,
    required this.linkText,
    required this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
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
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.4),
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
