import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../models/nutritionist_dashboard.dart';

/// ============================================
/// WIDGET: CHIP DE STATUS (com contagem)
/// ============================================
class StatusCountChip extends StatelessWidget {
  final PatientStatus status;
  final int count;
  final VoidCallback? onTap;

  const StatusCountChip({
    super.key,
    required this.status,
    required this.count,
    this.onTap,
  });

  /// Cor baseada no status
  Color get _color {
    switch (status) {
      case PatientStatus.evolving:
        return AppColors.success;
      case PatientStatus.attention:
        return AppColors.warning;
      case PatientStatus.noInteraction:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji + contagem
            Row(
              children: [
                Text(
                  status.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _color,
                    height: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Label
            Text(
              status.label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}