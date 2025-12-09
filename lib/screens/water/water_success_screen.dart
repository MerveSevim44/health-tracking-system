// 🎉 Water Success Screen - Goal achievement celebration
import 'package:flutter/material.dart';
import 'package:health_care/theme/water_theme.dart';
import 'package:health_care/widgets/water/water_blob.dart';
import 'package:health_care/widgets/water/blur_card.dart';
import 'dart:ui';

class WaterSuccessScreen extends StatefulWidget {
  final int achievedAmount;
  final int goalAmount;

  const WaterSuccessScreen({
    super.key,
    required this.achievedAmount,
    required this.goalAmount,
  });

  @override
  State<WaterSuccessScreen> createState() => _WaterSuccessScreenState();
}

class _WaterSuccessScreenState extends State<WaterSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blurred gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB3E5FC),
                  Color(0xFFE1F5FE),
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
          ),

          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),

          // Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated water blob
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: const WaterBlob(
                            progress: 1.0,
                            size: 240,
                            showFace: true,
                            animate: true,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Success message
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Emoji celebration
                              const Text(
                                '✨',
                                style: TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 16),

                              // Main title
                              Text(
                                'Well done!',
                                style: WaterTextStyles.displayMedium.copyWith(
                                  fontSize: 36,
                                  color: WaterColors.waterDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),

                              // Subtitle
                              Text(
                                'Water intake goal achieved',
                                style: WaterTextStyles.headlineMedium.copyWith(
                                  color: WaterColors.textLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Achievement stats card
                              BlurredGlassCard(
                                blurAmount: 15,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '${widget.achievedAmount}',
                                          style: WaterTextStyles.displayLarge
                                              .copyWith(
                                            color: WaterColors.waterDark,
                                          ),
                                        ),
                                        Text(
                                          ' ml',
                                          style:
                                              WaterTextStyles.headlineMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '/ ${widget.goalAmount} ml',
                                      style: WaterTextStyles.bodyLarge.copyWith(
                                        color: WaterColors.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: WaterColors.waterLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: 1.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient:
                                                WaterColors.waterBlobGradient,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Motivational message
                              Text(
                                'Keep up the great work!\nStay hydrated tomorrow too! 💧',
                                style: WaterTextStyles.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              // Back button
                              BluePrimaryButton(
                                text: 'Back',
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                width: 200,
                                icon: Icons.check_circle_outline,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating particles animation (optional decorative element)
          ..._buildFloatingParticles(),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(10, (index) {
      return Positioned(
        left: (index * 37.0) % MediaQuery.of(context).size.width,
        top: (index * 83.0) % MediaQuery.of(context).size.height,
        child: TweenAnimationBuilder(
          duration: Duration(milliseconds: 2000 + (index * 200)),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeInOut,
          builder: (context, double value, child) {
            return Opacity(
              opacity: (0.3 * value).clamp(0.0, 0.3),
              child: Transform.translate(
                offset: Offset(0, -50 * value),
                child: Container(
                  width: 20 + (index % 3) * 10,
                  height: 20 + (index % 3) * 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        WaterColors.waterPrimary.withValues(alpha: 0.4),
                        WaterColors.waterPrimary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          onEnd: () {
            // Loop animation
            if (mounted) {
              setState(() {});
            }
          },
        ),
      );
    });
  }
}
