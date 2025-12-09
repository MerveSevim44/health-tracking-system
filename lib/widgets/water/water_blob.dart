// 🌊 Water Blob Widget - Animated cute water drop character with progress fill
import 'package:flutter/material.dart';
import 'package:health_care/theme/water_theme.dart';

class WaterBlob extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final bool showFace;
  final bool animate;

  const WaterBlob({
    super.key,
    required this.progress,
    this.size = 200,
    this.showFace = true,
    this.animate = true,
  });

  @override
  State<WaterBlob> createState() => _WaterBlobState();
}

class _WaterBlobState extends State<WaterBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(WaterBlob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _WaterBlobPainter(
              progress: widget.animate ? _progressAnimation.value : widget.progress,
              showFace: widget.showFace,
            ),
          );
        },
      ),
    );
  }
}

class _WaterBlobPainter extends CustomPainter {
  final double progress;
  final bool showFace;

  _WaterBlobPainter({required this.progress, required this.showFace});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background blob (light blue)
    final bgPaint = Paint()
      ..color = WaterColors.waterLight
      ..style = PaintingStyle.fill;

    _drawBlobShape(canvas, center, radius, bgPaint);

    // Progress fill (gradient)
    final fillHeight = size.height * progress;
    final fillRect = Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight);

    final gradientPaint = Paint()
      ..shader = WaterColors.waterBlobGradient.createShader(fillRect)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipPath(_getBlobPath(center, radius));
    canvas.drawRect(fillRect, gradientPaint);
    canvas.restore();

    // Blob outline
    final outlinePaint = Paint()
      ..color = WaterColors.waterDark.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    _drawBlobShape(canvas, center, radius, outlinePaint);

    // Draw cute face
    if (showFace) {
      _drawFace(canvas, center, radius);
    }

    // Progress percentage text
    _drawProgressText(canvas, center);
  }

  void _drawBlobShape(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = _getBlobPath(center, radius);
    canvas.drawPath(path, paint);
  }

  Path _getBlobPath(Offset center, double radius) {
    final path = Path();

    // Water drop shape
    final topPoint = Offset(center.dx, center.dy - radius);
    final bottomPoint = Offset(center.dx, center.dy + radius * 0.8);
    
    path.moveTo(topPoint.dx, topPoint.dy);
    
    // Right curve
    path.cubicTo(
      center.dx + radius * 0.8, center.dy - radius * 0.5,
      center.dx + radius * 0.8, center.dy + radius * 0.3,
      bottomPoint.dx, bottomPoint.dy,
    );
    
    // Left curve
    path.cubicTo(
      center.dx - radius * 0.8, center.dy + radius * 0.3,
      center.dx - radius * 0.8, center.dy - radius * 0.5,
      topPoint.dx, topPoint.dy,
    );
    
    path.close();
    return path;
  }

  void _drawFace(Canvas canvas, Offset center, double radius) {
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Eyes
    final leftEye = Offset(center.dx - radius * 0.25, center.dy - radius * 0.1);
    final rightEye = Offset(center.dx + radius * 0.25, center.dy - radius * 0.1);
    
    canvas.drawCircle(leftEye, radius * 0.08, facePaint);
    canvas.drawCircle(rightEye, radius * 0.08, facePaint);

    // Pupils
    final pupilPaint = Paint()
      ..color = WaterColors.textDark
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(leftEye, radius * 0.04, pupilPaint);
    canvas.drawCircle(rightEye, radius * 0.04, pupilPaint);

    // Smile
    final smilePath = Path();
    final smileCenter = Offset(center.dx, center.dy + radius * 0.15);
    
    smilePath.moveTo(smileCenter.dx - radius * 0.3, smileCenter.dy);
    smilePath.quadraticBezierTo(
      smileCenter.dx, smileCenter.dy + radius * 0.15,
      smileCenter.dx + radius * 0.3, smileCenter.dy,
    );

    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(smilePath, smilePaint);

    // Blush cheeks
    final blushPaint = Paint()
      ..color = const Color(0xFFFF9999).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.45, center.dy + radius * 0.05),
        width: radius * 0.25,
        height: radius * 0.15,
      ),
      blushPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.45, center.dy + radius * 0.05),
        width: radius * 0.25,
        height: radius * 0.15,
      ),
      blushPaint,
    );
  }

  void _drawProgressText(Canvas canvas, Offset center) {
    final percentage = (progress * 100).toInt();
    final textSpan = TextSpan(
      text: '$percentage%',
      style: WaterTextStyles.displayMedium.copyWith(
        color: progress > 0.5 ? Colors.white : WaterColors.textDark,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + center.dy * 0.35,
      ),
    );
  }

  @override
  bool shouldRepaint(_WaterBlobPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.showFace != showFace;
  }
}
