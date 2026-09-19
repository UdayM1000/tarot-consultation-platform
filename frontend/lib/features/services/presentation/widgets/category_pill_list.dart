import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../models/category_model.dart';

class CategoryPillList extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;

  const CategoryPillList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1, // +1 for "All"
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final isSelected = isAll
              ? selectedCategoryId == null
              : selectedCategoryId == categories[index - 1].id;

          final label = isAll ? 'All Readings' : categories[index - 1].name;
          final icon = _getCategoryIcon(isAll ? 'ALL' : categories[index - 1].name);

          return InkWell(
            onTap: () {
              onCategorySelected(isAll ? null : categories[index - 1].id);
            },
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: isSelected
                    ? AppColors.sacredPurple.withValues(alpha: 0.25)
                    : AppColors.cardSurface,
                border: Border.all(
                  color: isSelected ? AppColors.astralGold : AppColors.cardBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.astralGold.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? AppColors.astralGold : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? AppColors.astralGold : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final upper = name.toUpperCase();
    if (upper.contains('TAROT')) {
      return Icons.style;
    } else if (upper.contains('RUNE')) {
      return Icons.shield_outlined;
    } else if (upper.contains('COMBO')) {
      return Icons.auto_awesome;
    }
    return Icons.explore_outlined;
  }
}
