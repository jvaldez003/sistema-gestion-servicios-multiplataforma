import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final cs = isDark ? _darkScheme : _lightScheme;
    final textTheme = isDark ? AppTypography.darkTextTheme : AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      textTheme: textTheme,
      fontFamily: GoogleFonts.inter().fontFamily,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        foregroundColor: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        titleTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          size: 24,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.border,
          disabledForegroundColor: AppColors.textSecondary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        prefixIconColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        suffixIconColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.borderDark : AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        iconColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        textColor: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        contentTextStyle: textTheme.bodyMedium,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.2),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        actionTextColor: AppColors.primaryLight,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
        dragHandleColor: isDark ? AppColors.borderDark : AppColors.border,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return isDark ? AppColors.textSecondaryDark : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.4);
          }
          return isDark ? AppColors.borderDark : AppColors.border;
        }),
      ),

      // Popup Menu
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        textStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
      ),
    );
  }

  // Light ColorScheme
  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFEDE8FF),
    onPrimaryContainer: const Color(0xFF1A0A3D),
    secondary: AppColors.primaryLight,
    onSecondary: Colors.white,
    tertiary: AppColors.adminAccent,
    onTertiary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    error: AppColors.error,
    onError: Colors.white,
    outline: AppColors.border,
    outlineVariant: const Color(0xFFCBD5E1),
    shadow: Colors.black,
    scrim: Colors.black,
  );

  // Dark ColorScheme
  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF2D1B69),
    onPrimaryContainer: const Color(0xFFEDE8FF),
    secondary: AppColors.primary,
    onSecondary: Colors.white,
    tertiary: AppColors.adminAccent,
    onTertiary: Colors.white,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textOnDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    error: AppColors.error,
    onError: Colors.white,
    outline: AppColors.borderDark,
    outlineVariant: const Color(0xFF1E293B),
    shadow: Colors.black,
    scrim: Colors.black,
  );
}
