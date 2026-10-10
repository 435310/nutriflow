import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../models/weight_entry.dart';

/// ============================================
/// WIDGET: GRÁFICO DE EVOLUÇÃO DE PESO
/// ============================================
/// Gráfico de linha customizado (sem lib externa).
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
    if (entries.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Registre pelo menos 2 pesos para ver o gráfico',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Ordena por data (mais antigo primeiro)
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
    if (entries.isEmpty) return;

    // ============================================
    // CONFIGURAÇÕES
    // ============================================
    const double paddingLeft = 40;
    const double paddingRight = 12;
    const double paddingTop = 20;
    const double paddingBottom = 28;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    // ============================================
    // CALCULAR MIN/MAX
    // ============================================
    double minWeight = entries.first.weightKg;
    double maxWeight = entries.first.weightKg;

    for (final entry in entries) {
      if (entry.weightKg < minWeight) minWeight = entry.weightKg;
      if (entry.weightKg > maxWeight) maxWeight = entry.weightKg;
    }

    // Adiciona margem
    final range = maxWeight - minWeight;
    final margin = range > 0 ? range * 0.2 : 1.0;

    minWeight -= margin;
    maxWeight += margin;

    // Se tiver meta, garante que ela apareça
    if (goalWeight != null) {
      if (goalWeight! < minWeight) minWeight = goalWeight! - margin;
      if (goalWeight! > maxWeight) maxWeight = goalWeight! + margin;
    }

    final totalRange = maxWeight - minWeight;

    // ============================================
    // FUNÇÕES AUXILIARES
    // ============================================
    double xForIndex(int index) {
      if (entries.length == 1) return paddingLeft + chartWidth / 2;
      return paddingLeft + (index / (entries.length - 1)) * chartWidth;
    }

    double yForWeight(double weight) {
      return paddingTop +
          chartHeight -
          ((weight - minWeight) / totalRange) * chartHeight;
    }

    // ============================================
    // LINHAS HORIZONTAIS (grid)
    // ============================================
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

      // Labels do eixo Y
      final weight = maxWeight - (i / 3) * totalRange;
      _drawText(
        canvas,
        '${weight.toStringAsFixed(0)}',
        Offset(0, y - 8),
        width: paddingLeft - 6,
        align: TextAlign.right,
      );
    }

    // ============================================
    // LINHA DA META (tracejada)
    // ============================================
    if (goalWeight != null) {
      final y = yForWeight(goalWeight!);
      final dashPaint = Paint()
        ..color = AppColors.warning.withValues(alpha: 0.6)
        ..strokeWidth = 2;

      const dashWidth = 6;
      const dashSpace = 4;
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

    // ============================================
    // ÁREA PREENCHIDA (gradiente)
    // ============================================
    final areaPath = Path()..moveTo(paddingLeft, paddingTop + chartHeight);

    for (int i = 0; i < entries.length; i++) {
      final x = xForIndex(i);
      final y = yForWeight(entries[i].weightKg);
      areaPath.lineTo(x, y);
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

    // ============================================
    // LINHA PRINCIPAL
    // ============================================
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

    // ============================================
    // PONTOS
    // ============================================
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