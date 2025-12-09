import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🌸 Breathing Flower Animation Widget
/// 
/// Creates a beautiful, soft lotus/flower breathing animation
/// with overlapping transparent petals that grow and shrink smoothly.
class BreathingFlowerAnimation extends StatefulWidget {
  final bool isAnimating;
  final Color color;
  final double size;
  final Duration breathDuration;

  const BreathingFlowerAnimation({
    super.key,
    this.isAnimating = false,
    required this.color,
    this.size = 200,
    this.breathDuration = const Duration(seconds: 4),
  });

  @override
  State<BreathingFlowerAnimation> createState() => _BreathingFlowerAnimationState();
}

class _BreathingFlowerAnimationState extends State<BreathingFlowerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.breathDuration,
    );

    // Create smooth inhale/exhale animation
    _scaleAnimation = TweenSequence<double>([
      // Inhale (0% to 50%) - expand
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      // Exhale (50% to 100%) - contract
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    if (widget.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(BreathingFlowerAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
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
          scale: _scaleAnimation.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: FlowerPainter(
              color: widget.color,
              animationValue: _scaleAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

/// 🎨 Custom Painter for the Flower/Lotus Shape
class FlowerPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  FlowerPainter({
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38; // Slightly larger petals

    // Create 8 overlapping petals in a flower pattern
    const int petalCount = 8;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount;
      
      // Calculate petal position
      final petalCenter = Offset(
        center.dx + (radius * 0.5) * math.cos(angle),
        center.dy + (radius * 0.5) * math.sin(angle),
      );

      // Soft pastel gradient with increased opacity for glow effect
      final gradient = RadialGradient(
        colors: [
          color.withOpacity(0.25), // Increased from 0.15
          color.withOpacity(0.35), // Increased from 0.25
          color.withOpacity(0.08), // Softer fade
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: petalCenter, radius: radius * 0.90), // Slightly larger
        )
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.srcOver;

      // Draw overlapping circles to create petal effect
      canvas.drawCircle(petalCenter, radius * 0.90, paint);
    }

    // Draw center circle with stronger opacity and soft glow
    final centerGradient = RadialGradient(
      colors: [
        color.withOpacity(0.40), // Increased from 0.3
        color.withOpacity(0.28), // Softer transition
        color.withOpacity(0.08), // Gentle fade
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final centerPaint = Paint()
      ..shader = centerGradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 0.65), // Slightly larger
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.65, centerPaint);
  }

  @override
  bool shouldRepaint(FlowerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
