import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apariencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(ctx: ctx, ref: ref, icon: Icons.light_mode_outlined, label: 'Claro', mode: ThemeMode.light, current: current),
            const SizedBox(height: 8),
            _ThemeOption(ctx: ctx, ref: ref, icon: Icons.dark_mode_outlined, label: 'Oscuro', mode: ThemeMode.dark, current: current),
            const SizedBox(height: 8),
            _ThemeOption(ctx: ctx, ref: ref, icon: Icons.brightness_auto_outlined, label: 'Sistema', mode: ThemeMode.system, current: current),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ayuda y Soporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Para soporte escríbenos a:'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'soporte@flowserv.app'));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Correo copiado al portapapeles'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'soporte@flowserv.app',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    const Icon(Icons.copy_rounded, color: AppColors.primary, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para copiar el correo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              'FlowServ es una plataforma SaaS para la gestión de citas y servicios.\n\n'
              '1. USO ACEPTABLE\nEl usuario se compromete a utilizar la plataforma de manera responsable y a no compartir sus credenciales.\n\n'
              '2. DATOS PERSONALES\nFlowServ almacena únicamente la información necesaria para la gestión de citas. No vendemos datos a terceros.\n\n'
              '3. PAGOS\nLos pagos procesados a través de la plataforma están sujetos a las políticas de MercadoPago y PayU Latam.\n\n'
              '4. RESPONSABILIDAD\nFlowServ no es responsable por la calidad de los servicios prestados por los negocios registrados.\n\n'
              '5. MODIFICACIONES\nNos reservamos el derecho de actualizar estos términos. Los usuarios serán notificados de cambios relevantes.\n\n'
              'Versión 1.0 — Mayo 2025\nContacto: soporte@flowserv.app',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark: return 'Oscuro';
      case ThemeMode.system: return 'Sistema';
      default: return 'Claro';
    }
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark: return Icons.dark_mode_outlined;
      case ThemeMode.system: return Icons.brightness_auto_outlined;
      default: return Icons.light_mode_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ajustes'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SettingsGroup(
            title: 'PREFERENCIAS',
            isDark: isDark,
            items: [
              _SettingsItem(
                icon: _themeModeIcon(themeMode),
                title: 'Tema',
                subtitle: _themeModeLabel(themeMode),
                isLast: true,
                onTap: () => _showThemeDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'INFORMACIÓN',
            isDark: isDark,
            items: [
              _SettingsItem(
                icon: Icons.help_outline_rounded,
                title: 'Ayuda y soporte',
                subtitle: 'Centro de ayuda y contacto',
                onTap: () => _showSupportDialog(context),
              ),
              _SettingsItem(
                icon: Icons.info_outline_rounded,
                title: 'Términos y condiciones',
                subtitle: 'Legal y políticas',
                onTap: () => _showTermsDialog(context),
              ),
              _SettingsItem(
                icon: Icons.code_rounded,
                title: 'Versión',
                subtitle: '1.0.0 (Build 2025)',
                isLast: true,
                onTap: null,
                showChevron: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Theme option inside dialog ────────────────────────────────────────────────

class _ThemeOption extends StatelessWidget {
  final BuildContext ctx;
  final WidgetRef ref;
  final IconData icon;
  final String label;
  final ThemeMode mode;
  final ThemeMode current;

  const _ThemeOption({
    required this.ctx,
    required this.ref,
    required this.icon,
    required this.label,
    required this.mode,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        ref.read(themeModeProvider.notifier).setMode(mode);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Settings group ────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final bool isDark;

  const _SettingsGroup({
    required this.title,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  letterSpacing: 1.1,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: isDark
                ? Border.all(color: AppColors.borderDark)
                : Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

// ── Settings item ─────────────────────────────────────────────────────────────

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLast;
  final bool showChevron;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isLast = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: showChevron
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                )
              : null,
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(height: 1, indent: 70, endIndent: 0),
      ],
    );
  }
}
