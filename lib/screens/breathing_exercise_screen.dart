import 'package:flutter/material.dart';
import 'package:health_care/widgets/breathing/flower_animation.dart';
import 'package:health_care/widgets/breathing/emotion_chip.dart';
import 'package:health_care/widgets/breathing/time_selector.dart';
import 'package:health_care/widgets/breathing/breathing_button.dart';
import 'package:health_care/theme/modern_colors.dart';

/// 🧘 Breathing Exercise Screen
/// 
/// A premium breathing exercise screen with:
/// - Animated lotus/flower breathing visualization
/// - Emotion selector
/// - Time duration selector
/// - Start button with gradient
/// - Full light/dark mode support
class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  String _selectedEmotion = 'Anger';
  int _selectedMinutes = 3;
  bool _isBreathing = false;

  void _startBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernAppColors.darkBg,
              ModernAppColors.cardBg,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Back button with title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: ModernAppColors.lightText),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Breathing',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: ModernAppColors.lightText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // 🌸 Animated Flower/Lotus Shape
                  BreathingFlowerAnimation(
                    isAnimating: _isBreathing,
                    color: ModernAppColors.accentGreen,
                    size: 280,
                    breathDuration: const Duration(seconds: 5),
                  ),

                  const SizedBox(height: 70),

                  // "Breath to reduce" Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Text(
                          'Breath to reduce',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: ModernAppColors.lightText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      EmotionPillSelector(
                        selectedEmotion: _selectedEmotion,
                        onEmotionSelected: (emotion) {
                          setState(() {
                            _selectedEmotion = emotion;
                          });
                        },
                        isDarkMode: true, // Use dark mode for modern theme
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Time Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 28.0),
                        child: Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: ModernAppColors.lightText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TimeDurationSelector(
                        selectedMinutes: _selectedMinutes,
                        onDurationSelected: (minutes) {
                          setState(() {
                            _selectedMinutes = minutes;
                          });
                        },
                        isDarkMode: true, // Use dark mode for modern theme
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Start Breathing Button
                  BreathingStartButton(
                    onPressed: _startBreathing,
                    isDarkMode: true, // Use dark mode for modern theme
                    text: _isBreathing ? 'Stop breathing' : 'Start breathing',
                  ),

                  const SizedBox(height: 40),

                  // Breathing Instructions
                  if (_isBreathing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Follow the flower rhythm\nInhale as it grows • Exhale as it shrinks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ModernAppColors.mutedText,
                          height: 1.6,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}