// 📁 lib/widgets/water/animated_water_drop.dart
// Animated hydration drop with fill level animation

import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedWaterDrop extends StatelessWidget {
  final double fillPercentage; // 0.0 to 1.0
  final Color fillColor;
  final double size;
  final String? drinkEmoji;

  const AnimatedWaterDrop({
    super.key,
    required this.fillPercentage,
    this.fillColor = const Color(0xFF4FC3F7),
    this.size = 200,
    this.drinkEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      tween: Tween(begin: 0.0, end: fillPercentage.clamp(0.0, 1.0)),
      builder: (context, animatedValue, child) {
        return Container(
          width: size,
          height: size * 1.2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Drop outline
              CustomPaint(
                size: Size(size, size * 1.2),
                painter: WaterDropPainter(
                  fillPercentage: animatedValue,
                  fillColor: fillColor,
                ),
              ),
              // Percentage text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (drinkEmoji != null) ...[
                    Text(
                      drinkEmoji!,
                      style: TextStyle(fontSize: size * 0.2),
                    ),
                    SizedBox(height: size * 0.05),
                  ],
                  Text(
                    '${(animatedValue * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.bold,
                      color: animatedValue > 0.5 ? Colors.white : fillColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaterDropPainter extends CustomPainter {
  final double fillPercentage;
  final Color fillColor;

  WaterDropPainter({
    required this.fillPercentage,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dropPath = _createDropPath(size);

    // Draw drop outline
    final outlinePaint = Paint()
      ..color = fillColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(dropPath, outlinePaint);

    // Clip to drop shape
    canvas.save();
    canvas.clipPath(dropPath);

    // Draw fill
    final fillHeight = size.height * (1 - fillPercentage);
    final fillRect = Rect.fromLTWH(0, fillHeight, size.width, size.height);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillColor.withValues(alpha: 0.8),
          fillColor,
        ],
      ).createShader(fillRect);

    canvas.drawRect(fillRect, fillPaint);

    // Draw wave effect at the top of fill
    if (fillPercentage > 0 && fillPercentage < 1) {
      _drawWave(canvas, size, fillHeight);
    }

    canvas.restore();
  }

  Path _createDropPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Top curve (water drop top)
    path.moveTo(width * 0.5, 0);
    path.quadraticBezierTo(
      width * 0.25,
      height * 0.15,
      width * 0.2,
      height * 0.35,
    );

    // Left curve
    path.quadraticBezierTo(
      width * 0.05,
      height * 0.6,
      width * 0.5,
      height,
    );

    // Right curve
    path.quadraticBezierTo(
      width * 0.95,
      height * 0.6,
      width * 0.8,
      height * 0.35,
    );

    path.quadraticBezierTo(
      width * 0.75,
      height * 0.15,
      width * 0.5,
      0,
    );

    path.close();
    return path;
  }

  void _drawWave(Canvas canvas, Size size, double yPosition) {
    final wavePath = Path();
    final waveAmplitude = 4.0;
    final waveLength = size.width / 3;

    wavePath.moveTo(0, yPosition);

    for (double x = 0; x <= size.width; x += 1) {
      final y = yPosition + 
          math.sin((x / waveLength) * 2 * math.pi) * waveAmplitude;
      wavePath.lineTo(x, y);
    }

    final wavePaint = Paint()
      ..color = fillColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant WaterDropPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.fillColor != fillColor;
  }
}
