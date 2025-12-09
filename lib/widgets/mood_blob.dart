import 'package:flutter/material.dart';

// 📁 lib/widgets/mood_blob.dart - Cute Blob Characters

class MoodBlob extends StatefulWidget {
  final double size;
  final Color color;
  final MoodExpression expression;
  final bool animated;

  const MoodBlob({
    super.key,
    this.size = 120,
    this.color = const Color(0xFFFFD166),
    this.expression = MoodExpression.happy,
    this.animated = false,
  });

  @override
  State<MoodBlob> createState() => _MoodBlobState();
}

class _MoodBlobState extends State<MoodBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animated ? _scaleAnimation.value : 1.0,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: BlobPainter(
              color: widget.color,
              expression: widget.expression,
            ),
          ),
        );
      },
    );
  }
}

enum MoodExpression {
  happy,
  calm,
  sad,
  anxious,
  angry,
  neutral,
}

class BlobPainter extends CustomPainter {
  final Color color;
  final MoodExpression expression;

  BlobPainter({required this.color, required this.expression});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw blob body (organic rounded shape)
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create blob shape using curves
    path.moveTo(center.dx, center.dy - radius);
    
    // Top curve
    path.cubicTo(
      center.dx + radius * 0.8, center.dy - radius * 1.1,
      center.dx + radius * 1.1, center.dy - radius * 0.3,
      center.dx + radius, center.dy,
    );
    
    // Right curve
    path.cubicTo(
      center.dx + radius * 1.1, center.dy + radius * 0.5,
      center.dx + radius * 0.6, center.dy + radius * 1.1,
      center.dx, center.dy + radius,
    );
    
    // Bottom curve
    path.cubicTo(
      center.dx - radius * 0.6, center.dy + radius * 1.1,
      center.dx - radius * 1.1, center.dy + radius * 0.5,
      center.dx - radius, center.dy,
    );
    
    // Left curve
    path.cubicTo(
      center.dx - radius * 1.1, center.dy - radius * 0.3,
      center.dx - radius * 0.8, center.dy - radius * 1.1,
      center.dx, center.dy - radius,
    );

    canvas.drawPath(path, paint);

    // Draw face based on expression
    _drawFace(canvas, size, center, radius);
  }

  void _drawFace(Canvas canvas, Size size, Offset center, double radius) {
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Eyes position
    final leftEye = Offset(center.dx - radius * 0.3, center.dy - radius * 0.15);
    final rightEye = Offset(center.dx + radius * 0.3, center.dy - radius * 0.15);

    switch (expression) {
      case MoodExpression.happy:
        // Smiling eyes (curves)
        _drawSmileEyes(canvas, leftEye, rightEye, radius * 0.15);
        // Happy mouth
        final mouthPath = Path();
        mouthPath.moveTo(center.dx - radius * 0.3, center.dy + radius * 0.15);
        mouthPath.quadraticBezierTo(
          center.dx, center.dy + radius * 0.4,
          center.dx + radius * 0.3, center.dy + radius * 0.15,
        );
        canvas.drawPath(mouthPath, mouthPaint);
        break;

      case MoodExpression.calm:
        // Closed peaceful eyes
        canvas.drawLine(
          Offset(leftEye.dx - radius * 0.1, leftEye.dy),
          Offset(leftEye.dx + radius * 0.1, leftEye.dy),
          mouthPaint,
        );
        canvas.drawLine(
          Offset(rightEye.dx - radius * 0.1, rightEye.dy),
          Offset(rightEye.dx + radius * 0.1, rightEye.dy),
          mouthPaint,
        );
        // Small smile
        final calmMouthPath = Path();
        calmMouthPath.moveTo(center.dx - radius * 0.2, center.dy + radius * 0.2);
        calmMouthPath.quadraticBezierTo(
          center.dx, center.dy + radius * 0.3,
          center.dx + radius * 0.2, center.dy + radius * 0.2,
        );
        canvas.drawPath(calmMouthPath, mouthPaint);
        break;

      case MoodExpression.sad:
        // Round eyes
        canvas.drawCircle(leftEye, radius * 0.08, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.08, eyePaint);
        // Sad mouth
        final sadMouthPath = Path();
        sadMouthPath.moveTo(center.dx - radius * 0.3, center.dy + radius * 0.3);
        sadMouthPath.quadraticBezierTo(
          center.dx, center.dy + radius * 0.15,
          center.dx + radius * 0.3, center.dy + radius * 0.3,
        );
        canvas.drawPath(sadMouthPath, mouthPaint);
        break;

      case MoodExpression.anxious:
        // Wide eyes
        canvas.drawCircle(leftEye, radius * 0.12, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.12, eyePaint);
        // Small O mouth
        canvas.drawCircle(
          Offset(center.dx, center.dy + radius * 0.25),
          radius * 0.08,
          mouthPaint,
        );
        break;

      case MoodExpression.angry:
        // Angry eyebrows
        canvas.drawLine(
          Offset(leftEye.dx - radius * 0.15, leftEye.dy - radius * 0.1),
          Offset(leftEye.dx + radius * 0.05, leftEye.dy),
          mouthPaint,
        );
        canvas.drawLine(
          Offset(rightEye.dx + radius * 0.15, rightEye.dy - radius * 0.1),
          Offset(rightEye.dx - radius * 0.05, rightEye.dy),
          mouthPaint,
        );
        // Angry mouth
        canvas.drawLine(
          Offset(center.dx - radius * 0.25, center.dy + radius * 0.3),
          Offset(center.dx + radius * 0.25, center.dy + radius * 0.3),
          mouthPaint,
        );
        break;

      case MoodExpression.neutral:
        // Round eyes
        canvas.drawCircle(leftEye, radius * 0.08, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.08, eyePaint);
        // Straight mouth
        canvas.drawLine(
          Offset(center.dx - radius * 0.25, center.dy + radius * 0.25),
          Offset(center.dx + radius * 0.25, center.dy + radius * 0.25),
          mouthPaint,
        );
        break;
    }
  }

  void _drawSmileEyes(Canvas canvas, Offset leftEye, Offset rightEye, double eyeRadius) {
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Smiling eyes (curves)
    final leftEyePath = Path();
    leftEyePath.moveTo(leftEye.dx - eyeRadius, leftEye.dy);
    leftEyePath.quadraticBezierTo(
      leftEye.dx, leftEye.dy + eyeRadius * 0.5,
      leftEye.dx + eyeRadius, leftEye.dy,
    );
    canvas.drawPath(leftEyePath, eyePaint);

    final rightEyePath = Path();
    rightEyePath.moveTo(rightEye.dx - eyeRadius, rightEye.dy);
    rightEyePath.quadraticBezierTo(
      rightEye.dx, rightEye.dy + eyeRadius * 0.5,
      rightEye.dx + eyeRadius, rightEye.dy,
    );
    canvas.drawPath(rightEyePath, eyePaint);
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.expression != expression;
  }
}
