import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int selectedIndex = 0;

  final List<CategoryItem> _categories = [
    CategoryItem(
      label: 'Para ti',
      icon: Icons.auto_awesome_outlined,
      color: AppColors.primary,
    ),
    CategoryItem(
      label: 'Barberías',
      icon: Icons.face_retouching_natural_outlined,
      color: const Color(0xFFF39C12),
    ),
    CategoryItem(
      label: 'Estéticas',
      icon: Icons.spa_outlined,
      color: const Color(0xFFE91E63),
    ),
    CategoryItem(
      label: 'Lavaderos',
      icon: Icons.directions_car_filled_outlined,
      color: const Color(0xFF3498DB),
    ),
    CategoryItem(
      label: 'Clínicas',
      icon: Icons.local_hospital_outlined,
      color: const Color(0xFF1ABC9C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final category = _categories[index];

          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color
                        : category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: category.color, width: 2)
                        : null,
                  ),
                  child: Icon(
                    category.icon,
                    color: isSelected ? Colors.white : category.color,
                    size: 30,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  category.label,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color:
                        isSelected ? category.color : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

