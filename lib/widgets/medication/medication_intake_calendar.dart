// 📁 lib/widgets/medication/medication_intake_calendar.dart
// Calendar widget showing medication intakes for a month

import 'package:flutter/material.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/theme/app_theme.dart';

class MedicationIntakeCalendar extends StatefulWidget {
  final String medicationId;
  final Map<DateTime, List<MedicationIntake>> intakesByDate;
  final Function(DateTime) onDateTap;

  const MedicationIntakeCalendar({
    super.key,
    required this.medicationId,
    required this.intakesByDate,
    required this.onDateTap,
  });

  @override
  State<MedicationIntakeCalendar> createState() => _MedicationIntakeCalendarState();
}

class _MedicationIntakeCalendarState extends State<MedicationIntakeCalendar> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildWeekDays(),
          const SizedBox(height: 12),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left, color: Color(0xFF9D84FF)),
        ),
        Text(
          '${monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right, color: Color(0xFF9D84FF)),
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['Pz', 'Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9D84FF).withValues(alpha: 0.7),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final List<Widget> dayWidgets = [];

    // Empty cells before first day
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayMonth.year, _displayMonth.month, day);
      dayWidgets.add(_buildDayCell(date));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayWidgets.length,
      itemBuilder: (context, index) => dayWidgets[index],
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final intakes = _getIntakesForDate(date);
    final hasTaken = intakes.where((i) => i.taken).isNotEmpty;
    final hasScheduled = intakes.isNotEmpty;

    return GestureDetector(
      onTap: hasScheduled ? () => widget.onDateTap(date) : null,
      child: Container(
        decoration: BoxDecoration(
          color: hasTaken
              ? const Color(0xFF06D6A0).withValues(alpha: 0.15)
              : hasScheduled
                  ? const Color(0xFFFFD166).withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(color: const Color(0xFF9D84FF), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: hasScheduled ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            if (hasScheduled) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasTaken)
                    const Icon(Icons.check_circle, size: 12, color: Color(0xFF06D6A0))
                  else
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD166),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<MedicationIntake> _getIntakesForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return widget.intakesByDate[dateKey] ?? [];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
