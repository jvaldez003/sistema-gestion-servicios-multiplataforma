import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/registration_provider.dart';
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

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Indicator
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepCircle(1, false, isCompleted: true),
                        _buildStepLine(isCompleted: true),
                        _buildStepCircle(2, true),
                        _buildStepLine(),
                        _buildStepCircle(3, false),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Paso 2 de 3 · Datos personales',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title and Description
              Center(
                child: Column(
                  children: [
                    Text(
                      'Tus datos personales',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: 26),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Cuéntanos quién eres para personalizar tu experiencia.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Nombre completo',
                      hint: 'Juan Pérez',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: 'Teléfono',
                      hint: '+57 300 123 4567',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      text: 'Continuar',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Actualizar datos en el provider
                          ref.read(registrationProvider.notifier).updateData(
                                name: _nameController.text.trim(),
                                phoneNumber: _phoneController.text.trim(),
                              );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterStepThreeScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
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
}
