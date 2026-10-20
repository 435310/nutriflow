import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../models/symptom_report.dart';

/// ============================================
/// WIDGET: CARD DE SINTOMAS NO DASHBOARD
/// ============================================
class SymptomCard extends StatelessWidget {
  final SymptomReport? latestReport;
  final VoidCallback onTap;

  const SymptomCard({
    super.key,
    this.latestReport,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasReport = latestReport != null;

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
                    color: const Color(0xFF9B51E0).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Color(0xFF9B51E0),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Como você está se sentindo?',
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (!hasReport)
              // Nenhum relato ainda
              Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toque para relatar sintomas ou dificuldades',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              )
            else
              // Já tem relato
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Último relato: ${latestReport!.formattedDate}',
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    latestReport!.summary,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9B51E0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Novo relato',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}