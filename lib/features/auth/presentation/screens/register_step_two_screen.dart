import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../providers/registration_provider.dart';
import '../widgets/auth_shared_widgets.dart';
import 'register_step_three_screen.dart';

class RegisterStepTwoScreen extends ConsumerStatefulWidget {
  const RegisterStepTwoScreen({super.key});

  @override
  ConsumerState<RegisterStepTwoScreen> createState() =>
      _RegisterStepTwoScreenState();
}

class _RegisterStepTwoScreenState extends ConsumerState<RegisterStepTwoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = ref.read(registrationProvider);
    _nameController.text = data.name;
    _phoneController.text = data.phoneNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(registrationProvider.notifier).updateData(
            name: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterStepThreeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthStepIndicator(current: 2),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Tus datos personales',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Cuéntanos quién eres para personalizar tu experiencia.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthFieldLabel('Nombre completo'),
                  AppInput(
                    hint: 'Juan Pérez',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthFieldLabel('Teléfono'),
                  AppInput(
                    hint: '+57 300 123 4567',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _continue(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu teléfono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(label: 'Continuar', onPressed: _continue),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
