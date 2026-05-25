import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF8344FF);
  static const Color primaryLight = Color(0xFF9B6AFF);
  static const Color primaryDark = Color(0xFF6C2CE6);

  // Backgrounds — light
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Backgrounds — dark
  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceVariantDark = Color(0xFF252540);

  // Texts — light
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Colors.white;

  // Texts — dark
  static const Color textOnDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = primary;
  static const Color borderDark = Color(0xFF2D3748);

  // Semantic / accent tokens (valores existentes en el codebase, ahora como tokens)
  static const Color adminAccent = Color(0xFFF97316);   // Naranja admin
  static const Color positiveGreen = Color(0xFF10B981); // Ingresos / completado
  static const Color accentPurple = Color(0xFFC084FC);  // Gráficas / secundario
  static const Color accentAmber = Color(0xFFFB923C);   // Publicaciones / cálido
}
