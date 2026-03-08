import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  static TextStyle get h1 => textTheme.displayLarge!;
  static TextStyle get h2 => textTheme.displayMedium!;
  static TextStyle get h3 => textTheme.titleLarge!;
  static TextStyle get titleLarge => textTheme.titleLarge!;
  static TextStyle get titleMedium => textTheme.titleMedium!;
  static TextStyle get bodyLarge => textTheme.bodyLarge!;
  static TextStyle get bodyMedium => textTheme.bodyMedium!;
  static TextStyle get bodySmall => textTheme.bodySmall!;

  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
    );
  }
}
