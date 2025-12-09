import 'package:flutter/material.dart';
import 'package:health_care/widgets/breathing/flower_animation.dart';
import 'package:health_care/widgets/breathing/emotion_chip.dart';
import 'package:health_care/widgets/breathing/time_selector.dart';
import 'package:health_care/widgets/breathing/breathing_button.dart';

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
    // Pure white/light background for pastel aesthetic (no dark mode)
    const backgroundColor = Color(0xFFFFFFF); // Pure white
    const flowerColor = Color(0xFFC7A6FF); // Pastel Lilac
    const textColor = Color(0xFF2D3436);
    const subtitleColor = Color(0xFF8B92A0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 🔷 Title
                const Text(
                  'Breathing',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 60),

                // 🌸 Animated Flower/Lotus Shape (Pastel Lilac)
                BreathingFlowerAnimation(
                  isAnimating: _isBreathing,
                  color: flowerColor,
                  size: 280, // Slightly larger
                  breathDuration: const Duration(seconds: 5),
                ),

                const SizedBox(height: 70),

                // 🔷 "Breath to reduce" Section
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
                          color: textColor,
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
                      isDarkMode: false, // Always light mode
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // 🔷 Time Selector
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
                          color: textColor,
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
                      isDarkMode: false, // Always light mode
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // 🔵 Start Breathing Button
                BreathingStartButton(
                  onPressed: _startBreathing,
                  isDarkMode: false, // Always light mode
                  text: _isBreathing ? 'Stop breathing' : 'Start breathing',
                ),

                const SizedBox(height: 40),

                // 💡 Optional: Breathing Instructions
                if (_isBreathing)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Follow the flower rhythm\nInhale as it grows • Exhale as it shrinks',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
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
    );
  }
}