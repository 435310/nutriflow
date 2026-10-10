import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../models/weight_entry.dart';

/// ============================================
/// WIDGET: MINI GRÁFICO DE PESO
/// ============================================
class MiniWeightChart extends StatelessWidget {
  final List<WeightEntry> entries;
  final double height;

  const MiniWeightChart({
    super.key,
    required this.entries,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return SizedBox(height: height);
    }

    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _MiniChartPainter(entries: sorted),
        size: Size.infinite,
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  final List<WeightEntry> entries;

  _MiniChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    double minWeight = entries.first.weightKg;
    double maxWeight = entries.first.weightKg;

    for (final entry in entries) {
      if (entry.weightKg < minWeight) minWeight = entry.weightKg;
      if (entry.weightKg > maxWeight) maxWeight = entry.weightKg;
    }

    final range = maxWeight - minWeight;
    final margin = range > 0 ? range * 0.15 : 1.0;
    minWeight -= margin;
    maxWeight += margin;
    final totalRange = maxWeight - minWeight;

    double xForIndex(int index) {
      return (index / (entries.length - 1)) * size.width;
    }

    double yForWeight(double weight) {
      return size.height -
          ((weight - minWeight) / totalRange) * size.height;
    }

    final areaPath = Path()..moveTo(0, size.height);
    for (int i = 0; i < entries.length; i++) {
      areaPath.lineTo(
        xForIndex(i),
        yForWeight(entries[i].weightKg),
      );
    }
    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, areaPaint);

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
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);

    final lastX = xForIndex(entries.length - 1);
    final lastY = yForWeight(entries.last.weightKg);

    canvas.drawCircle(
      Offset(lastX, lastY),
      6,
      Paint()..color = AppColors.primary,
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      6,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}