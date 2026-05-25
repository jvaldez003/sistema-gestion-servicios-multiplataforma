import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final AppButtonVariant variant;
  final IconData? prefixIcon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
    this.height = 52,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null || widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (!_disabled) setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (!_disabled) {
      setState(() => _pressed = false);
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _PrimaryBody(
          label: widget.label,
          isLoading: widget.isLoading,
          disabled: _disabled,
          fullWidth: widget.fullWidth,
          height: widget.height,
          prefixIcon: widget.prefixIcon,
        );
      case AppButtonVariant.secondary:
        return _SecondaryBody(
          label: widget.label,
          isLoading: widget.isLoading,
          disabled: _disabled,
          fullWidth: widget.fullWidth,
          height: widget.height,
          prefixIcon: widget.prefixIcon,
          isDark: isDark,
        );
      case AppButtonVariant.ghost:
        return _GhostBody(
          label: widget.label,
          isLoading: widget.isLoading,
          disabled: _disabled,
          fullWidth: widget.fullWidth,
          height: widget.height,
          prefixIcon: widget.prefixIcon,
        );
    }
  }
}

// ─── Primary (gradient + shadow) ────────────────────────────────────────────

class _PrimaryBody extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool disabled;
  final bool fullWidth;
  final double height;
  final IconData? prefixIcon;

  const _PrimaryBody({
    required this.label,
    required this.isLoading,
    required this.disabled,
    required this.fullWidth,
    required this.height,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: disabled ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        height: height,
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: disabled ? AppColors.border : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: -2,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.05),
            onTap: null, // handled by parent GestureDetector
            child: Center(child: _ButtonContent(label: label, isLoading: isLoading, prefixIcon: prefixIcon, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

// ─── Secondary (outlined) ───────────────────────────────────────────────────

class _SecondaryBody extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool disabled;
  final bool fullWidth;
  final double height;
  final IconData? prefixIcon;
  final bool isDark;

  const _SecondaryBody({
    required this.label,
    required this.isLoading,
    required this.disabled,
    required this.fullWidth,
    required this.height,
    required this.isDark,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: disabled ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        height: height,
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disabled
                ? AppColors.border
                : AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            highlightColor: AppColors.primary.withValues(alpha: 0.04),
            onTap: null,
            child: Center(
              child: _ButtonContent(
                label: label,
                isLoading: isLoading,
                prefixIcon: prefixIcon,
                color: disabled ? AppColors.textSecondary : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ghost (text only) ──────────────────────────────────────────────────────

class _GhostBody extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool disabled;
  final bool fullWidth;
  final double height;
  final IconData? prefixIcon;

  const _GhostBody({
    required this.label,
    required this.isLoading,
    required this.disabled,
    required this.fullWidth,
    required this.height,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: disabled ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        height: height,
        width: fullWidth ? double.infinity : null,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            onTap: null,
            child: Center(
              child: _ButtonContent(
                label: label,
                isLoading: isLoading,
                prefixIcon: prefixIcon,
                color: disabled ? AppColors.textSecondary : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared content ─────────────────────────────────────────────────────────

class _ButtonContent extends StatelessWidget {
  final String label;
  final bool isLoading;
  final IconData? prefixIcon;
  final Color color;

  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.color,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 2.5,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, color: color, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
