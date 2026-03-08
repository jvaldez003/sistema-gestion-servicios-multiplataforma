import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index == totalSteps - 1 ? 0 : 8,
            ),
            decoration: BoxDecoration(
              color: isActive ? activeColor : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
