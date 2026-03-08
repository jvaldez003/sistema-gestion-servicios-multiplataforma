import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/social_outline_button.dart';
import '../providers/registration_provider.dart';
import 'register_step_two_screen.dart';

class RegisterStepOneScreen extends ConsumerStatefulWidget {
  const RegisterStepOneScreen({super.key});

  @override
  ConsumerState<RegisterStepOneScreen> createState() =>
      _RegisterStepOneScreenState();
}

class _RegisterStepOneScreenState extends ConsumerState<RegisterStepOneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if data exists
    final data = ref.read(registrationProvider);
    _emailController.text = data.email;
    _passwordController.text = data.password;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                        _buildStepCircle(1, true),
                        _buildStepLine(),
                        _buildStepCircle(2, false),
                        _buildStepLine(),
                        _buildStepCircle(3, false),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Paso 1 de 3 · Credenciales',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title and Description
              Text(
                'Crea tu cuenta',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ingresa tu correo y una contraseña segura para comenzar.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Google Register Button
              SocialOutlineButton(
                text: 'Registrarse con Google',
                onPressed: () {
                  // Implementación de Google ya integrada en AuthNotifier
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'o con tu correo',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelWithAsterisk('Correo electrónico'),
                    CustomTextField(
                      label: '',
                      hint: 'tu@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Por favor ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildLabelWithAsterisk('Contraseña'),
                    CustomTextField(
                      label: '',
                      hint: 'Mínimo 6 caracteres',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildLabelWithAsterisk('Confirmar contraseña'),
                    CustomTextField(
                      label: '',
                      hint: 'Repite tu contraseña',
                      prefixIcon: Icons.lock_reset_outlined,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor confirma tu contraseña';
                        }
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      text: 'Continuar',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Guardar datos en el provider
                          ref.read(registrationProvider.notifier).updateData(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterStepTwoScreen(),
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

  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 2,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildLabelWithAsterisk(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}
