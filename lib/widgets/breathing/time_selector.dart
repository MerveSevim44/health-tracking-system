import 'package:flutter/material.dart';

/// ⏱️ Time Duration Selector Widget
/// 
/// Horizontal list of time durations with selected highlighting
class TimeDurationSelector extends StatelessWidget {
  final int selectedMinutes;
  final Function(int) onDurationSelected;
  final bool isDarkMode;

  const TimeDurationSelector({
    super.key,
    required this.selectedMinutes,
    required this.onDurationSelected,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final durations = [1, 2, 3, 4, 5, 6];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: durations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final minutes = durations[index];
          final isSelected = minutes == selectedMinutes;
          return _TimeChip(
            minutes: minutes,
            isSelected: isSelected,
            isDarkMode: isDarkMode,
            onTap: () => onDurationSelected(minutes),
          );
        },
      ),
    );
  }
}

/// Individual time duration chip
class _TimeChip extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _TimeChip({
    required this.minutes,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pastel aesthetic colors
    const Color selectedTextColor = Color(0xFF2D3436);
    const Color unselectedTextColor = Color(0xFFB8B8B8);
    const Color underlineColor = Color(0xFFC7A6FF); // Pastel Lilac

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$minutes min',
              style: TextStyle(
                fontSize: isSelected ? 18 : 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedTextColor : unselectedTextColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            // Animated underline for selected item
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: 3,
              width: isSelected ? 40 : 0,
              decoration: BoxDecoration(
                color: underlineColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
