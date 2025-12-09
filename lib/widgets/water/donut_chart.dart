// 📊 Donut Chart Widget - For water statistics visualization
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:health_care/theme/water_theme.dart';

class DonutChartData {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const DonutChartData({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class DonutChart extends StatelessWidget {
  final List<DonutChartData> data;
  final double size;
  final double strokeWidth;

  const DonutChart({
    super.key,
    required this.data,
    this.size = 200,
    this.strokeWidth = 30,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutChartPainter(
          data: data,
          total: total,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: _buildCenterText(total),
        ),
      ),
    );
  }

  Widget _buildCenterText(double total) {
    if (data.isEmpty) return const SizedBox();

    final primaryValue = data.first.value;
    final percentage = ((primaryValue / total) * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$percentage%',
          style: WaterTextStyles.displayMedium.copyWith(fontSize: 36),
        ),
        const SizedBox(height: 4),
        Text(
          data.first.label,
          style: WaterTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutChartData> data;
  final double total;
  final double strokeWidth;

  _DonutChartPainter({
    required this.data,
    required this.total,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    var startAngle = -math.pi / 2; // Start from top

    for (var item in data) {
      final sweepAngle = (item.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.total != total;
  }
}

// Legend widget for donut chart
class DonutChartLegend extends StatelessWidget {
  final List<DonutChartData> data;

  const DonutChartLegend({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 16,
                  color: item.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: WaterTextStyles.bodyLarge,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
