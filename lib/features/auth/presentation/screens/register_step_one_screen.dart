import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../providers/registration_provider.dart';
import '../widgets/auth_shared_widgets.dart';
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

  void _continue() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(registrationProvider.notifier).updateData(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterStepTwoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Step indicator ────────────────────────────────────────
            AuthStepIndicator(current: 1),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Crea tu cuenta',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Ingresa tu correo y una contraseña segura para comenzar.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Google button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: FaIcon(FontAwesomeIcons.google, size: 18),
                label: const Text('Registrarse con Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppColors.textOnDark
                      : AppColors.textPrimary,
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'o con tu correo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Form ──────────────────────────────────────────────────
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthFieldLabel('Correo electrónico'),
                  AppInput(
                    hint: 'tu@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Por favor ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthFieldLabel('Contraseña'),
                  AppInput(
                    hint: 'Mínimo 6 caracteres',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthFieldLabel('Confirmar contraseña'),
                  AppInput(
                    hint: 'Repite tu contraseña',
                    prefixIcon: Icons.lock_reset_outlined,
                    obscureText: true,
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _continue(),
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

