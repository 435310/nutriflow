import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../models/weight_entry.dart';

/// ============================================
/// WIDGET: ITEM DO HISTÓRICO DE PESO
/// ============================================
class WeightHistoryItem extends StatelessWidget {
  final WeightEntry entry;
  final double? previousWeight;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const WeightHistoryItem({
    super.key,
    required this.entry,
    this.previousWeight,
    this.onTap,
    this.onDelete,
  });

  /// Variação desde o registro anterior
  double? get _delta {
    if (previousWeight == null) return null;
    return entry.weightKg - previousWeight!;
  }

  @override
  Widget build(BuildContext context) {
    final delta = _delta;
    final isLosing = delta != null && delta < 0;
    final isNeutral = delta != null && delta == 0;

    Color deltaColor = AppColors.textSecondary;
    IconData? deltaIcon;
    String? deltaText;

    if (delta != null && !isNeutral) {
      deltaColor = isLosing ? AppColors.success : AppColors.warning;
      deltaIcon = isLosing ? Icons.trending_down : Icons.trending_up;
      deltaText =
          '${isLosing ? '▼' : '▲'} ${delta.abs().toStringAsFixed(1)} kg';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Ícone de calendário
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.monitor_weight_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            // Data
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.formattedDate,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.notes!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Peso
            Text(
              '${entry.weightKg.toStringAsFixed(1)} kg',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            // Variação
            if (deltaText != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (deltaIcon != null) ...[
                      Icon(deltaIcon, size: 12, color: deltaColor),
                      const SizedBox(width: 2),
                    ],
                    Text(
                      deltaText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: deltaColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Botão excluir (opcional)
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}