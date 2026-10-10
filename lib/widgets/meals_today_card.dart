import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';

/// ============================================
/// WIDGET: CARD DE REFEIÇÕES DE HOJE
/// ============================================
class MealsTodayCard extends StatelessWidget {
  final int registered;
  final int total;
  final VoidCallback? onTap;

  const MealsTodayCard({
    super.key,
    required this.registered,
    required this.total,
    this.onTap,
  });

  /// Calcula o progresso (0.0 a 1.0)
  double get _progress {
    if (total == 0) return 0;
    return (registered / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.restaurant_outlined,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Refeições de hoje', style: AppTextStyles.h3),
                const Spacer(),
                Text(
                  '$registered/$total',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Barra de progresso
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.secondary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Texto de status
            Text(
              registered == 0
                  ? 'Nenhuma refeição registrada ainda'
                  : registered >= total
                      ? '🎉 Todas as refeições registradas!'
                      : 'Faltam ${total - registered} refeição${total - registered > 1 ? 's' : ''}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}