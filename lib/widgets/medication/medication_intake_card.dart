import 'package:flutter/material.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/models/medication_type_config.dart';

/// Card widget for displaying medication intake with all times
class MedicationIntakeCard extends StatelessWidget {
  final MedicationFirebase medication;
  final MedicationIntake? intake;
  final String period; // 'morning', 'afternoon', or 'evening'
  final VoidCallback? onTap;
  final VoidCallback? onCheck;

  const MedicationIntakeCard({
    super.key,
    required this.medication,
    this.intake,
    required this.period,
    this.onTap,
    this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    final type = MedicationTypeExtension.fromFirebaseValue(medication.type ?? 'tablet') ?? MedicationType.tablet;
    final isTaken = intake?.taken ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: type.color.withValues(alpha: isTaken ? 0.2 : 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isTaken 
                  ? Colors.black.withValues(alpha: 0.05)
                  : type.color.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with type
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    type.color.withValues(alpha: isTaken ? 0.15 : 0.25),
                    type.color.withValues(alpha: isTaken ? 0.1 : 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: type.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                type.icon,
                color: type.color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    medication.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      color: isTaken
                          ? const Color(0xFF8B92A0)
                          : const Color(0xFF2D3436),
                      decoration: isTaken ? TextDecoration.lineThrough : null,
                      decorationThickness: 2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Dosage
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          type.color.withValues(alpha: 0.2),
                          type.color.withValues(alpha: 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: type.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.medication_liquid,
                          size: 14,
                          color: type.color,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            medication.dosage,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: type.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Time period badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _buildTimeBadges(medication.frequency),
                  ),
                ],
              ),
            ),
            // Time and Check Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: type.color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: type.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeForPeriod(period),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: type.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Take Medication Button
                if (onCheck != null)
                  GestureDetector(
                    onTap: isTaken ? null : onCheck,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: isTaken
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFF8B92A0),
                                  const Color(0xFF707885),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  type.color,
                                  type.color.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isTaken
                            ? []
                            : [
                                BoxShadow(
                                  color: type.color.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 1,
                                ),
                              ],
                      ),
                      child: Icon(
                        isTaken ? Icons.check_circle : Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeBadges(MedicationFrequency frequency) {
    final List<Widget> badges = [];

    if (frequency.morning) {
      badges.add(_buildTimeBadge('Morning', period == 'morning'));
    }
    if (frequency.afternoon) {
      badges.add(_buildTimeBadge('Afternoon', period == 'afternoon'));
    }
    if (frequency.evening) {
      badges.add(_buildTimeBadge('Evening', period == 'evening'));
    }

    return badges;
  }

  Widget _buildTimeBadge(String label, bool isCurrentPeriod) {
    final type = MedicationTypeExtension.fromFirebaseValue(medication.type ?? 'tablet') ?? MedicationType.tablet;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentPeriod
            ? type.color.withValues(alpha: 0.25)
            : type.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: isCurrentPeriod
            ? Border.all(color: type.color, width: 1.5)
            : Border.all(color: type.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isCurrentPeriod ? FontWeight.bold : FontWeight.w600,
          color: type.color,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  String _getTimeForPeriod(String period) {
    switch (period) {
      case 'morning':
        return '09:00';
      case 'afternoon':
        return '14:00';
      case 'evening':
        return '20:00';
      default:
        return '09:00';
    }
  }
}
