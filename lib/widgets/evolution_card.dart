import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';

/// ============================================
/// WIDGET: CARD DE EVOLUÇÃO DE PESO
/// ============================================
class EvolutionCard extends StatelessWidget {
  final double currentWeight;
  final double? initialWeight;
  final double? goalWeight;
  final VoidCallback? onTap;

  const EvolutionCard({
    super.key,
    required this.currentWeight,
    this.initialWeight,
    this.goalWeight,
    this.onTap,
  });

  /// Calcula quanto já perdeu/ganhou
  double? get _delta {
    if (initialWeight == null) return null;
    return currentWeight - initialWeight!;
  }

  /// Calcula progresso até a meta (0.0 a 1.0)
  double get _progress {
    if (initialWeight == null || goalWeight == null) return 0;
    final total = (initialWeight! - goalWeight!).abs();
    if (total == 0) return 1;
    final done = (initialWeight! - currentWeight).abs();
    return (done / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final delta = _delta;
    final isLosing = delta != null && delta < 0;

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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.monitor_weight_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Evolução', style: AppTextStyles.h3),
              ],
            ),

            const SizedBox(height: 20),

            // Peso atual + variação
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Peso atual
                Text(
                  currentWeight.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'kg',
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ),
                const Spacer(),

                // Variação
                if (delta != null && delta != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (isLosing ? AppColors.success : AppColors.warning)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLosing ? Icons.trending_down : Icons.trending_up,
                          size: 16,
                          color: isLosing
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isLosing ? '▼' : '▲'} ${delta.abs().toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isLosing
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            // Legenda
            Text(
              delta != null
                  ? (isLosing
                      ? 'Perdidos desde o início'
                      : 'Ganhos desde o início')
                  : 'Peso atual',
              style: AppTextStyles.caption,
            ),

            const SizedBox(height: 20),

            // Barra de progresso até a meta
            if (goalWeight != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso até a meta',
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Meta: ${goalWeight!.toStringAsFixed(1)} kg',
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}