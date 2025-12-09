import 'package:flutter/material.dart';

/// 🔵 Breathing Start Button Widget
/// 
/// Large, rounded gradient button with soft shadow
class BreathingStartButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDarkMode;
  final String text;
  final bool isActive;

  const BreathingStartButton({
    super.key,
    required this.onPressed,
    this.isDarkMode = false,
    this.text = 'Start breathing',
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    // Blue-Lilac gradient for pastel aesthetic
    const List<Color> gradientColors = [
      Color(0xFFA889FF), // Lilac start
      Color(0xFF6C63FF), // Blue-purple end
    ];

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(40), // More rounded
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.35), // Softer shadow
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? onPressed : null,
          borderRadius: BorderRadius.circular(40),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
