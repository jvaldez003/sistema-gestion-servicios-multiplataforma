import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cambiar contraseña',
          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPasswordField(ctx, currentCtrl, 'Contraseña actual'),
            const SizedBox(height: 12),
            _buildPasswordField(ctx, newCtrl, 'Nueva contraseña'),
            const SizedBox(height: 12),
            _buildPasswordField(ctx, confirmCtrl, 'Confirmar nueva contraseña'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red),
                );
                return;
              }
              if (newCtrl.text.length < 6) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres'), backgroundColor: Colors.red),
                );
                return;
              }

              final user = FirebaseAuth.instance.currentUser;
              if (user == null || user.email == null) return;

              try {
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentCtrl.text,
                );
                await user.reauthenticateWithCredential(credential);
                await user.updatePassword(newCtrl.text);

                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Contraseña actualizada correctamente'),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                final msg = e.code == 'wrong-password' || e.code == 'invalid-credential'
                    ? 'La contraseña actual es incorrecta.'
                    : 'Error al actualizar: ${e.message}';
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context, TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 8),
            Text(
              '¿Eliminar cuenta?',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        content: Text(
          'Esta acción es permanente e irreversible. Todos tus datos serán eliminados y no podrás recuperarlos.',
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final passwordCtrl = TextEditingController();
    final authenticated = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirmar identidad',
          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Por seguridad, ingresa tu contraseña para confirmar la eliminación.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(ctx, passwordCtrl, 'Contraseña'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );

    if (authenticated != true || !mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: passwordCtrl.text,
        );
        await user.reauthenticateWithCredential(credential);
      }

      await user.delete();

      if (mounted) {
        await ref.read(authNotifierProvider.notifier).signOut();
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? 'Contraseña incorrecta. No se eliminó la cuenta.'
          : 'Error al eliminar: ${e.message}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Seguridad',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildSecurityGroup(
            context,
            'Seguridad y Privacidad',
            [
              _buildSecurityItem(
                context,
                icon: Icons.lock_outline_rounded,
                title: 'Cambiar contraseña',
                subtitle: 'Actualiza tu clave de acceso',
                onTap: _changePassword,
              ),
              _buildSecurityItem(
                context,
                icon: Icons.delete_forever_outlined,
                title: 'Eliminar cuenta',
                subtitle: 'Esta acción es permanente',
                color: AppColors.error,
                onTap: _deleteAccount,
                isLast: true,
              ),
            ],
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityGroup(BuildContext context, String title, List<Widget> items, {required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: isDark
                ? Border.all(color: AppColors.borderDark)
                : Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSecurityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color ?? AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          trailing: trailing ??
              Icon(Icons.chevron_right_rounded, color: color ?? AppColors.textSecondary),
          onTap: trailing == null ? onTap : null,
        ),
        if (!isLast)
          Divider(height: 1, indent: 70, color: Theme.of(context).dividerColor),
      ],
    );
  }
}
