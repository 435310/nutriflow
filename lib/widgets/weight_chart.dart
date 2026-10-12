import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../models/weight_entry.dart';

/// ============================================
/// WIDGET: GRÁFICO DE EVOLUÇÃO DE PESO
/// ============================================
class WeightChart extends StatelessWidget {
  final List<WeightEntry> entries;
  final double? goalWeight;
  final double height;

  const WeightChart({
    super.key,
    required this.entries,
    this.goalWeight,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    // Caso 1: lista vazia
    if (entries.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 32,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Sem dados para exibir',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Caso 2: só 1 registro — mostra um ponto sozinho
    if (entries.length == 1) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${entries.first.weightKg.toStringAsFixed(1)} kg',
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'Adicione mais registros para ver o gráfico',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Caso 3: 2+ registros — mostra o gráfico
    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _WeightChartPainter(
          entries: sorted,
          goalWeight: goalWeight,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// ============================================
// PAINTER DO GRÁFICO
// ============================================
class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final double? goalWeight;

  _WeightChartPainter({
    required this.entries,
    this.goalWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    const double paddingLeft = 40;
    const double paddingRight = 12;
    const double paddingTop = 20;
    const double paddingBottom = 28;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    double minWeight = entries.first.weightKg;
    double maxWeight = entries.first.weightKg;

    for (final entry in entries) {
      if (entry.weightKg < minWeight) minWeight = entry.weightKg;
      if (entry.weightKg > maxWeight) maxWeight = entry.weightKg;
    }

    final range = maxWeight - minWeight;
    final margin = range > 0 ? range * 0.2 : 1.0;

    minWeight -= margin;
    maxWeight += margin;

    if (goalWeight != null) {
      if (goalWeight! < minWeight) minWeight = goalWeight! - margin;
      if (goalWeight! > maxWeight) maxWeight = goalWeight! + margin;
    }

    final totalRange = maxWeight - minWeight;

    double xForIndex(int index) {
      if (entries.length == 1) return paddingLeft + chartWidth / 2;
      return paddingLeft + (index / (entries.length - 1)) * chartWidth;
    }

    double yForWeight(double weight) {
      return paddingTop +
          chartHeight -
          ((weight - minWeight) / totalRange) * chartHeight;
    }

    // Grid
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = paddingTop + (i / 3) * chartHeight;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );

      final weight = maxWeight - (i / 3) * totalRange;
      _drawText(
        canvas,
        weight.toStringAsFixed(0),
        Offset(0, y - 8),
        width: paddingLeft - 6,
        align: TextAlign.right,
      );
    }

    // Linha da meta
    if (goalWeight != null) {
      final y = yForWeight(goalWeight!);
      final dashPaint = Paint()
        ..color = AppColors.warning.withValues(alpha: 0.6)
        ..strokeWidth = 2;

      const dashWidth = 6.0;
      const dashSpace = 4.0;
      double x = paddingLeft;
      while (x < size.width - paddingRight) {
        canvas.drawLine(
          Offset(x, y),
          Offset((x + dashWidth).clamp(0, size.width - paddingRight), y),
          dashPaint,
        );
        x += dashWidth + dashSpace;
      }

      _drawText(
        canvas,
        'Meta',
        Offset(size.width - paddingRight - 30, y - 14),
        width: 30,
        align: TextAlign.right,
        color: AppColors.warning,
        fontSize: 10,
      );
    }

    // Área preenchida
    final areaPath = Path()..moveTo(paddingLeft, paddingTop + chartHeight);

    for (int i = 0; i < entries.length; i++) {
      areaPath.lineTo(
        xForIndex(i),
        yForWeight(entries[i].weightKg),
      );
    }

    areaPath.lineTo(
      xForIndex(entries.length - 1),
      paddingTop + chartHeight,
    );
    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.primary.withValues(alpha: 0.02),
        ],
      ).createShader(
        Rect.fromLTWH(paddingLeft, paddingTop, chartWidth, chartHeight),
      );

    canvas.drawPath(areaPath, areaPaint);

    // Linha principal
    final linePath = Path();
    for (int i = 0; i < entries.length; i++) {
      final x = xForIndex(i);
      final y = yForWeight(entries[i].weightKg);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);

    // Pontos
    final pointPaint = Paint()..color = AppColors.primary;
    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < entries.length; i++) {
      final x = xForIndex(i);
      final y = yForWeight(entries[i].weightKg);
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
      canvas.drawCircle(Offset(x, y), 5, pointBorderPaint);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double width = 40,
    TextAlign align = TextAlign.left,
    Color color = AppColors.textSecondary,
    double fontSize = 11,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.goalWeight != goalWeight;
  }
}