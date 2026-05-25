import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../providers/auth_notifier.dart';
import 'register_step_one_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authNotifierProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (!mounted) return;
      final authState = ref.read(authNotifierProvider);
      if (authState.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.errorMessage ?? 'Error al iniciar sesión'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? 'Error al iniciar sesión con Google'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient header ───────────────────────────────────────
            _Header(),

            // ── Form section ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido de nuevo',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ingresa tus credenciales para continuar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppInput(
                      label: 'Correo electrónico',
                      hint: 'ejemplo@correo.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: AppSpacing.md),

                    AppInput(
                      label: 'Contraseña',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    // Error inline
                    if (authState.status == AuthStatus.error)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          authState.errorMessage ?? 'Ocurrió un error',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    AppButton(
                      label: 'Iniciar sesión',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleLogin,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Divider ───────────────────────────────────────
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'O continúa con',
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

                    const SizedBox(height: AppSpacing.xl),

                    // ── Google button ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _handleGoogleSignIn,
                        icon: FaIcon(FontAwesomeIcons.google, size: 18),
                        label: const Text('Continuar con Google'),
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

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Register link ─────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes una cuenta? ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterStepOneScreen(),
                            ),
                          ),
                          child: Text(
                            'Regístrate aquí',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient header with logo ─────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statusBarH = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: statusBarH + 24, bottom: 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative circles
          Positioned(
            top: -10,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Logo card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
