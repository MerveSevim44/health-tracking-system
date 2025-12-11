import 'package:flutter/material.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/widgets/medication/pill_icon.dart';

// 📁 lib/widgets/medication/medication_card.dart

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTap;
  final VoidCallback? onTakeMedication;
  final bool showCategory;

  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
    this.onTakeMedication,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              medication.color.withValues(alpha: 0.15),
              medication.color.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: medication.color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: medication.color.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            PillIcon(
              iconType: medication.icon,
              color: medication.color,
              size: 32,
              withBackground: true,
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Dosage with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: medication.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.medication_liquid,
                              size: 14,
                              color: medication.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              medication.dosage,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: medication.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showCategory) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: medication.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getCategoryText(medication.category),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: medication.color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Meal timing if not anytime
                  if (medication.mealTiming != MealTiming.anytime) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 13,
                          color: const Color(0xFF8B92A0).withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _getMealTimingText(medication.mealTiming),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8B92A0).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Time and Check Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: medication.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(medication.time),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: medication.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Take Medication Button
                if (onTakeMedication != null)
                  GestureDetector(
                    onTap: onTakeMedication,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: medication.color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: medication.color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                if (medication.mealTiming != MealTiming.anytime) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 12,
                        color: const Color(0xFF8B92A0).withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _getMealTimingText(medication.mealTiming),
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF8B92A0).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryText(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.morning:
        return 'Morning';
      case MedicationCategory.afternoon:
        return 'Afternoon';
      case MedicationCategory.evening:
        return 'Evening';
      case MedicationCategory.night:
        return 'Night';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getMealTimingText(MealTiming timing) {
    switch (timing) {
      case MealTiming.beforeMeal:
        return 'Before meal';
      case MealTiming.afterMeal:
        return 'After meal';
      case MealTiming.withMeal:
        return 'With meal';
      case MealTiming.anytime:
        return '';
    }
  }
}
