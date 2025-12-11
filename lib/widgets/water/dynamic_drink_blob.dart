// 🥤 Dynamic Drink Blob Widget - Animasyonlu içecek gösterimi
// Seçilen içecek türüne göre dinamik ikon ve animasyonlu dolum efekti

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:health_care/theme/water_theme.dart';
import 'package:health_care/widgets/water/drink_selector.dart';

/// Dinamik içecek blob widget'ı - seçilen içecek türüne göre değişir
class DynamicDrinkBlob extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final DrinkType drinkType; // Seçilen içecek türü
  final double size;
  final bool animate;

  const DynamicDrinkBlob({
    super.key,
    required this.progress,
    required this.drinkType,
    this.size = 220,
    this.animate = true,
  });

  @override
  State<DynamicDrinkBlob> createState() => _DynamicDrinkBlobState();
}

class _DynamicDrinkBlobState extends State<DynamicDrinkBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

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
      curve: Curves.easeInOutCubic,
    ));

    // İkon için hafif scale animasyonu
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(DynamicDrinkBlob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ));
      _controller.forward(from: 0);
    }
    
    // İçecek türü değiştiğinde animasyon
    if (oldWidget.drinkType != widget.drinkType) {
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
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Arka plan çember
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _DrinkBlobPainter(
                  progress: widget.animate ? _progressAnimation.value : widget.progress,
                  color: widget.drinkType.color,
                ),
              ),
              
              // İçecek ikonu (ortada, ölçekli)
              Transform.scale(
                scale: widget.animate ? _scaleAnimation.value : 1.0,
                child: Icon(
                  widget.drinkType.icon,
                  size: widget.size * 0.35,
                  color: widget.progress > 0.5 
                    ? Colors.white.withValues(alpha: 0.9)
                    : widget.drinkType.color.withValues(alpha: 0.7),
                ),
              ),
              
              // Progress yüzdesi (alt kısımda)
              Positioned(
                bottom: widget.size * 0.15,
                child: _buildProgressText(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressText() {
    final percentage = (widget.progress * 100).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.progress > 0.5 
          ? Colors.white.withValues(alpha: 0.9)
          : widget.drinkType.color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.drinkType.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$percentage%',
        style: WaterTextStyles.labelLarge.copyWith(
          color: widget.progress > 0.5 
            ? widget.drinkType.color
            : WaterColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

/// Custom painter for circular blob with fill animation
class _DrinkBlobPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DrinkBlobPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Arka plan çember (açık renk)
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress dolum efekti (gradient ile)
    final fillHeight = size.height * progress;
    final fillRect = Rect.fromLTWH(
      0, 
      size.height - fillHeight, 
      size.width, 
      fillHeight,
    );

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0.8),
          color,
        ],
      ).createShader(fillRect)
      ..style = PaintingStyle.fill;

    canvas.save();
    // Çember şeklinde clip
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    
    // Dalgalı efekt için
    final wavePath = Path();
    wavePath.moveTo(0, size.height - fillHeight);
    
    // Sinüs dalgası efekti
    for (double i = 0; i <= size.width; i++) {
      final waveOffset = 8 * math.sin((i / size.width) * 4 * math.pi + progress * 2 * math.pi);
      wavePath.lineTo(i, size.height - fillHeight + waveOffset);
    }
    
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();
    
    canvas.drawPath(wavePath, gradientPaint);
    canvas.restore();

    // Dış çember border
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, borderPaint);

    // İç highlight çemberi (üst kısımda)
    if (progress < 0.9) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(center.dx - radius * 0.3, center.dy - radius * 0.4),
        radius * 0.15,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DrinkBlobPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}


