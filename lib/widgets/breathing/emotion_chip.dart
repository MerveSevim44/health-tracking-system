import 'package:flutter/material.dart';

/// 💊 Emotion Pill Selector Widget
/// 
/// A stylish segmented chip UI for selecting emotions to reduce
class EmotionPillSelector extends StatelessWidget {
  final String selectedEmotion;
  final Function(String) onEmotionSelected;
  final bool isDarkMode;

  const EmotionPillSelector({
    super.key,
    required this.selectedEmotion,
    required this.onEmotionSelected,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final emotions = ['Anger', 'Anxiety', 'Stress', 'Sadness'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: emotions.map((emotion) {
        final isSelected = emotion == selectedEmotion;
        return _EmotionChip(
          label: emotion,
          isSelected: isSelected,
          isDarkMode: isDarkMode,
          onTap: () => onEmotionSelected(emotion),
        );
      }).toList(),
    );
  }
}

/// Individual emotion chip/pill
class _EmotionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _EmotionChip({
    required this.label,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pastel aesthetic colors (soft grayscale + lilac)
    const Color selectedBgColor = Color(0xFFC7A6FF); // Pastel Lilac
    const Color selectedTextColor = Colors.white;
    const Color unselectedBgColor = Color(0xFFF2F2F2); // Soft grayscale
    const Color unselectedTextColor = Color(0xFF6B7280);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : unselectedBgColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedBgColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? selectedTextColor : unselectedTextColor,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
