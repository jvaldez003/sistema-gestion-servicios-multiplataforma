import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/business_providers.dart';

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

class CategorySelector extends ConsumerStatefulWidget {
  const CategorySelector({super.key});

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
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
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final category = _categories[index];

          return GestureDetector(
            onTap: () {
              setState(() => selectedIndex = index);
              // index 0 = "Para ti" means no filter
              final category = index == 0 ? null : _categories[index].label;
              ref.read(categoryFilterProvider.notifier).state = category;
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: isSelected ? category.color : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: category.color.withValues(alpha:0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                    border: Border.all(
                      color: isSelected ? category.color : Colors.black.withValues(alpha:0.05),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    color: isSelected ? Colors.white : category.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  category.label,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
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

