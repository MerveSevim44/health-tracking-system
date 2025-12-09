import 'package:flutter/material.dart';
import 'package:health_care/models/medication_model.dart';

// 📁 lib/widgets/medication/action_buttons.dart

class ActionButtons extends StatelessWidget {
  final Medication medication;
  final Function(MedicationStatus) onAction;

  const ActionButtons({
    super.key,
    required this.medication,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Take Button
        _ActionButton(
          label: 'Take',
          icon: Icons.check_circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF06D6A0), Color(0xFF48E5BB)],
          ),
          onTap: () => onAction(MedicationStatus.taken),
        ),
        const SizedBox(height: 12),
        // Skip and Postpone Row
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Skip',
                icon: Icons.close,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                ),
                isSmall: true,
                onTap: () => onAction(MedicationStatus.skipped),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'Postpone',
                icon: Icons.schedule,
                gradient: const LinearGradient(
                  colors: [Color(0xFF9D84FF), Color(0xFFB8A4FF)],
                ),
                isSmall: true,
                onTap: () => onAction(MedicationStatus.postponed),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool isSmall;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 16 : 20,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient)
                  .colors
                  .first
                  .withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isSmall ? 20 : 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
