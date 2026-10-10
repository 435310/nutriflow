import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../models/patient_filter.dart';

/// ============================================
/// WIDGET: CHIPS DE FILTRO DE PACIENTES
/// ============================================
class PatientFilterChips extends StatelessWidget {
  final PatientFilter selected;
  final ValueChanged<PatientFilter> onChanged;
  final Map<PatientFilter, int>? counts;

  const PatientFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PatientFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = PatientFilter.values[index];
          final isSelected = filter == selected;
          final count = counts?[filter];

          return _FilterChip(
            filter: filter,
            isSelected: isSelected,
            count: count,
            onTap: () => onChanged(filter),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final PatientFilter filter;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter.emoji,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}