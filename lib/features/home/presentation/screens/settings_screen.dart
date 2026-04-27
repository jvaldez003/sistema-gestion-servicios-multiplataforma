import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Ajustes',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildSettingsGroup(
            'Preferencias',
            [
              _buildSettingsItem(
                context,
                icon: Icons.language_rounded,
                title: 'Idioma',
                subtitle: 'Español (Latinoamérica)',
              ),
              _buildSettingsItem(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Tema',
                subtitle: 'Claro',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSettingsGroup(
            'Información',
            [
              _buildSettingsItem(
                context,
                icon: Icons.help_outline_rounded,
                title: 'Ayuda y soporte',
                subtitle: 'Centro de ayuda y contacto',
              ),
              _buildSettingsItem(
                context,
                icon: Icons.info_outline_rounded,
                title: 'Términos y condiciones',
                subtitle: 'Legal y políticas',
              ),
              _buildSettingsItem(
                context,
                icon: Icons.code_rounded,
                title: 'Versión',
                subtitle: '1.0.0 (Build 2024)',
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
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

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.bodySmall,
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          onTap: () {},
        ),
        if (!isLast)
          const Divider(height: 1, indent: 70, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}
