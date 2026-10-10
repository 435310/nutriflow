import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../models/meal.dart';

/// ============================================
/// WIDGET: SELETOR DE TIPO DE REFEIÇÃO
/// ============================================
class MealTypeSelector extends StatelessWidget {
  final MealType? selected;
  final ValueChanged<MealType> onChanged;

  const MealTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: MealType.values.map((type) {
        final isSelected = type == selected;
        return _MealTypeChip(
          type: type,
          isSelected: isSelected,
          onTap: () => onChanged(type),
        );
      }).toList(),
    );
  }
}

class _MealTypeChip extends StatelessWidget {
  final MealType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              type.shortLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}