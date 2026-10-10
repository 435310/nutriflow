import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../models/meal.dart';

/// ============================================
/// WIDGET: ITEM DE ALIMENTO (na lista)
/// ============================================
class FoodItemField extends StatelessWidget {
  final FoodItem food;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;

  const FoodItemField({
    super.key,
    required this.food,
    this.onRemove,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppColors.primary,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // Nome + quantidade
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${food.quantity.toStringAsFixed(food.quantity.truncate() == food.quantity ? 0 : 1)} ${food.unit}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          // Botão editar (opcional)
          if (onEdit != null)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),

          // Botão remover
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}