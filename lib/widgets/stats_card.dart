import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';

/// ============================================
/// WIDGET: CARD DE ESTATÍSTICAS
/// ============================================
class StatsCard extends StatelessWidget {
  final List<StatItem> items;
  final String title;
  final IconData icon;

  const StatsCard({
    super.key,
    required this.items,
    this.title = 'Estatísticas',
    this.icon = Icons.insights_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.h3),
            ],
          ),

          const SizedBox(height: 20),

          // Grid de estatísticas (2 colunas)
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: items.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    child: _StatTile(item: item),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================
// ITEM DE ESTATÍSTICA
// ============================================
class StatItem {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const StatItem({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });
}

// ============================================
// TILE DE ESTATÍSTICA (interno)
// ============================================
class _StatTile extends StatelessWidget {
  final StatItem item;

  const _StatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            item.label,
            style: AppTextStyles.caption,
          ),

          const SizedBox(height: 6),

          // Valor + ícone opcional
          Row(
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 16,
                  color: item.color ?? AppColors.primary,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  item.value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: item.color ?? AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}