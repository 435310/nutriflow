import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../models/nutritionist_dashboard.dart';
import 'user_avatar.dart';

/// ============================================
/// WIDGET: ITEM DA LISTA DE PACIENTES
/// ============================================
class PatientListItem extends StatelessWidget {
  final PatientSummary patient;
  final VoidCallback? onTap;

  const PatientListItem({
    super.key,
    required this.patient,
    this.onTap,
  });

  /// Cor do status
  Color get _statusColor {
    switch (patient.status) {
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            UserAvatar(
              name: patient.name,
              size: UserAvatarSize.small,
            ),

            const SizedBox(width: 12),

            // Nome + última atividade
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          patient.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Indicador de status (bolinha)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _statusColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          patient.lastActivity,
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        patient.timeAgo,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Seta
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}