import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Seguridad',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildSecurityGroup(
            'Acceso',
            [
              _buildSecurityItem(
                context,
                icon: Icons.lock_outline_rounded,
                title: 'Cambiar contraseña',
                subtitle: 'Actualiza tu clave de acceso',
              ),
              _buildSecurityItem(
                context,
                icon: Icons.fingerprint_rounded,
                title: 'Biometría',
                subtitle: 'Usa tu huella o rostro para entrar',
                trailing: Switch(value: true, onChanged: (val) {}),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSecurityGroup(
            'Privacidad',
            [
              _buildSecurityItem(
                context,
                icon: Icons.visibility_off_outlined,
                title: 'Modo incógnito',
                subtitle: 'Oculta tu actividad reciente',
                trailing: Switch(value: false, onChanged: (val) {}),
              ),
              _buildSecurityItem(
                context,
                icon: Icons.delete_forever_outlined,
                title: 'Eliminar cuenta',
                subtitle: 'Esta acción es permanente',
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
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
  }) {
    return ListTile(
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
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall,
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: trailing == null ? () {} : null,
    );
  }
}
