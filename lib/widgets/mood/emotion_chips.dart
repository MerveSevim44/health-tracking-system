// 📁 lib/widgets/mood/emotion_chips.dart
// Emotion selection chips for mood tracking

import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/models/mood_firebase_model.dart';

class EmotionChips extends StatelessWidget {
  final List<String> selectedEmotions;
  final Function(String) onEmotionToggle;
  final List<String> availableEmotions;

  const EmotionChips({
    super.key,
    required this.selectedEmotions,
    required this.onEmotionToggle,
    this.availableEmotions = EmotionsList.common,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableEmotions.map((emotion) {
        final isSelected = selectedEmotions.contains(emotion);
        return _EmotionChip(
          emotion: emotion,
          isSelected: isSelected,
          onTap: () => onEmotionToggle(emotion),
        );
      }).toList(),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  final String emotion;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmotionChip({
    required this.emotion,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = EmotionsList.getEmoji(emotion);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.emotionHappy.withOpacity(0.2)
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.emotionHappy
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              emotion,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.lightTextPrimary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
