import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// ── Step indicator ────────────────────────────────────────────────────────────

class AuthStepIndicator extends StatelessWidget {
  final int current;
  const AuthStepIndicator({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthStepCircle(step: 1, current: current),
            AuthStepLine(filled: current > 1),
            AuthStepCircle(step: 2, current: current),
            AuthStepLine(filled: current > 2),
            AuthStepCircle(step: 3, current: current),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Paso $current de 3 · ${_label(current)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  String _label(int step) {
    switch (step) {
      case 1: return 'Credenciales';
      case 2: return 'Datos personales';
      default: return 'Finalizar';
    }
  }
}

class AuthStepCircle extends StatelessWidget {
  final int step;
  final int current;
  const AuthStepCircle({super.key, required this.step, required this.current});

  @override
  Widget build(BuildContext context) {
    final isCompleted = step < current;
    final isActive = step == current;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: (isActive || isCompleted) ? AppColors.primary : AppColors.border,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}

class AuthStepLine extends StatelessWidget {
  final bool filled;
  const AuthStepLine({super.key, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ── Required field label ──────────────────────────────────────────────────────

class AuthFieldLabel extends StatelessWidget {
  final String text;
  const AuthFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}
