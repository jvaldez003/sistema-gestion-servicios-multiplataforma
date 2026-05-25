import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../providers/auth_notifier.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(
          _emailController.text.trim(),
        );

    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.errorMessage ?? 'Error al enviar el correo'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Correo enviado'),
            content: const Text(
              'Si el correo existe en nuestro sistema, recibirás un enlace para restablecer tu contraseña en unos momentos.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Icon ─────────────────────────────────────────────
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.lock_reset_outlined,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Recuperar contraseña',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppInput(
                  label: 'Correo electrónico',
                  hint: 'ejemplo@correo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => isLoading ? null : _handleSubmit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  label: 'Enviar enlace',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
