import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class AppInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscured = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fillColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    );
    final idleBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText && _obscured,
        readOnly: widget.readOnly,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        autofocus: widget.autofocus,
        style: TextStyle(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          filled: true,
          fillColor: fillColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.prefixIcon != null ? 0 : 16,
            vertical: widget.maxLines > 1 ? 14 : 0,
          ),
          constraints: widget.maxLines == 1
              ? const BoxConstraints(minHeight: 52, maxHeight: 52)
              : null,
          border: idleBorder,
          enabledBorder: idleBorder,
          focusedBorder: focusBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder.copyWith(
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  size: 20,
                  color: _hasFocus
                      ? AppColors.primary
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                )
              : widget.suffix,
          hintStyle: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          labelStyle: TextStyle(
            color: _hasFocus
                ? AppColors.primary
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          counterText: '',
          errorStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
