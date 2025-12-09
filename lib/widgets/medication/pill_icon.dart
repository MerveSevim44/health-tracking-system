import 'package:flutter/material.dart';
import 'package:health_care/models/medication_model.dart';

// 📁 lib/widgets/medication/pill_icon.dart

class PillIcon extends StatelessWidget {
  final MedicationIcon iconType;
  final Color color;
  final double size;
  final bool withBackground;

  const PillIcon({
    super.key,
    required this.iconType,
    required this.color,
    this.size = 32,
    this.withBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon = _getIconData();

    if (withBackground) {
      return Container(
        width: size * 1.8,
        height: size * 1.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size * 0.5),
        ),
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      );
    }

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }

  IconData _getIconData() {
    switch (iconType) {
      case MedicationIcon.pill:
        return Icons.medication;
      case MedicationIcon.capsule:
        return Icons.medication_liquid;
      case MedicationIcon.bottle:
        return Icons.local_pharmacy;
      case MedicationIcon.vitamin:
        return Icons.star; // Vitamin represented as star/supplement
      case MedicationIcon.injection:
        return Icons.vaccines;
      case MedicationIcon.drops:
        return Icons.water_drop;
      case MedicationIcon.syrup:
        return Icons.local_drink;
    }
  }
}

// Icon selector for add medication screen
class PillIconSelector extends StatelessWidget {
  final MedicationIcon selectedIcon;
  final Function(MedicationIcon) onIconSelected;

  const PillIconSelector({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: MedicationIcon.values.map((iconType) {
        final isSelected = selectedIcon == iconType;
        return GestureDetector(
          onTap: () => onIconSelected(iconType),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE8DEFF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF9D84FF)
                    : const Color(0xFFE8E8E8),
                width: 2,
              ),
            ),
            child: Center(
              child: PillIcon(
                iconType: iconType,
                color: isSelected
                    ? const Color(0xFF9D84FF)
                    : const Color(0xFF8B92A0),
                size: 28,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
