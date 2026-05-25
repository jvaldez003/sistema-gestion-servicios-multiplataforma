import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'step_indicator.dart';

class ContentStepper extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final List<Widget> steps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String nextButtonText;
  final Color themeColor;

  const ContentStepper({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.steps,
    required this.onNext,
    required this.onBack,
    this.nextButtonText = 'Continuar',
    this.themeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                if (currentStep > 1)
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left, size: 20),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Paso $currentStep de $totalSteps',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StepIndicator(
              currentStep: currentStep,
              totalSteps: totalSteps,
              activeColor: themeColor,
            ),
          ),
          const SizedBox(height: 32),
          // Step Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: steps[currentStep - 1],
            ),
          ),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nextButtonText,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          // Extra space for keyboard if needed
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
