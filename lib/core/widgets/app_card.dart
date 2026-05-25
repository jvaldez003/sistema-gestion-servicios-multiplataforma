import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final bool elevated;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius = 16,
    this.color,
    this.elevated = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  bool get _tappable => widget.onTap != null;

  void _onTapDown(TapDownDetails _) {
    if (_tappable) setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (_tappable) {
      setState(() => _pressed = false);
      widget.onTap?.call();
    }
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(widget.borderRadius);

    final cardColor = widget.color ??
        (isDark ? AppColors.surfaceDark : AppColors.surface);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: radius,
            border: isDark
                ? Border.all(color: AppColors.borderDark, width: 1)
                : null,
            boxShadow: widget.elevated && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
