import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary =
      Color(0xFF8344FF); // Púrpura principal extraído del diseño
  static const Color primaryLight = Color(0xFF9B6AFF);
  static const Color primaryDark = Color(0xFF6C2CE6);

  // Backgrounds
  static const Color background =
      Color(0xFFFAFAFA); // Gris muy claro para el fondo
  static const Color surface = Colors.white;

  // Texts
  static const Color textPrimary = Color(0xFF1E293B); // Texto oscuro principal
  static const Color textSecondary = Color(0xFF64748B); // Texto secundario gris
  static const Color textLight =
      Colors.white; // Texto claro sobre colores oscuros

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = primary;
}
