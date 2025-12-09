import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 📁 lib/widgets/medication/day_selector.dart

class DaySelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DaySelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, now);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF9D84FF), Color(0xFFB8A4FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isToday && !isSelected
                      ? const Color(0xFF9D84FF).withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF9D84FF).withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 3),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : const Color(0xFF8B92A0),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Medication load indicator
                  _buildMedicationIndicator(isSelected, _getMedicationCount(date)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationIndicator(bool isSelected, int count) {
    if (count == 0) return const SizedBox(height: 8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count.clamp(0, 3),
        (index) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : const Color(0xFF9D84FF).withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  int _getMedicationCount(DateTime date) {
    // This would be replaced with actual data from provider
    // For now, return sample counts
    return date.weekday % 3 + 1;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
