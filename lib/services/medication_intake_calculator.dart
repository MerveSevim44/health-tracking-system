// 📁 lib/services/medication_intake_calculator.dart
// Automatic intake calculation and generation

import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/models/medication_type_config.dart';

/// Service for calculating and generating medication intakes automatically
class MedicationIntakeCalculator {
  /// Calculate total number of intakes based on medication details
  /// Returns number of intakes that can be generated
  static int calculateTotalIntakes({
    required MedicationType type,
    required int totalAmount,
    required String dosage,
    required MedicationFrequency frequency,
  }) {
    // Parse dosage to get amount per intake
    final amountPerIntake = _parseDosageAmount(dosage, type);
    if (amountPerIntake == 0) return 0;

    // Calculate how many times per day
    int timesPerDay = 0;
    if (frequency.morning) timesPerDay++;
    if (frequency.afternoon) timesPerDay++;
    if (frequency.evening) timesPerDay++;

    if (timesPerDay == 0) return 0;

    // For tablets/pills/capsules: simple division
    if (_isCountableType(type)) {
      final totalIntakes = totalAmount ~/ amountPerIntake;
      return totalIntakes;
    }

    // For liquids (ml): divide total by amount per intake
    if (_isLiquidType(type)) {
      final totalIntakes = totalAmount ~/ amountPerIntake;
      return totalIntakes;
    }

    // For patches: duration-based
    if (type == MedicationType.patch) {
      // Assuming each patch lasts 24-72 hours, default to 1 day
      return totalAmount;
    }

    // Default calculation
    return totalAmount ~/ amountPerIntake;
  }

  /// Calculate number of days the medication will last
  static int calculateDurationDays({
    required int totalIntakes,
    required MedicationFrequency frequency,
  }) {
    int timesPerDay = 0;
    if (frequency.morning) timesPerDay++;
    if (frequency.afternoon) timesPerDay++;
    if (frequency.evening) timesPerDay++;

    if (timesPerDay == 0) return 0;

    return (totalIntakes / timesPerDay).ceil();
  }

  /// Generate list of intake dates and times
  static List<IntakeSchedule> generateIntakeSchedule({
    required DateTime startDate,
    required int durationDays,
    required MedicationFrequency frequency,
    required String dosage,
  }) {
    final List<IntakeSchedule> schedules = [];

    for (int day = 0; day < durationDays; day++) {
      final date = startDate.add(Duration(days: day));

      if (frequency.morning) {
        schedules.add(IntakeSchedule(
          date: date,
          time: '09:00',
          period: 'morning',
          plannedDose: dosage,
        ));
      }

      if (frequency.afternoon) {
        schedules.add(IntakeSchedule(
          date: date,
          time: '14:00',
          period: 'afternoon',
          plannedDose: dosage,
        ));
      }

      if (frequency.evening) {
        schedules.add(IntakeSchedule(
          date: date,
          time: '20:00',
          period: 'evening',
          plannedDose: dosage,
        ));
      }
    }

    return schedules;
  }

  /// Generate intakes for weekly schedule
  /// Only creates intakes on specified weekdays
  static List<IntakeSchedule> generateWeeklyIntakeSchedule({
    required DateTime startDate,
    required int durationDays,
    required MedicationFrequency frequency,
    required String dosage,
    required Set<int> weekDays, // 1=Monday, 7=Sunday
  }) {
    final List<IntakeSchedule> schedules = [];
    
    for (int day = 0; day < durationDays; day++) {
      final date = startDate.add(Duration(days: day));
      final weekday = date.weekday; // 1=Monday, 7=Sunday
      
      // Skip if this day is not in selected weekdays
      if (!weekDays.contains(weekday)) continue;

      // Morning intake
      if (frequency.morning) {
        schedules.add(IntakeSchedule(
          date: date,
          time: '09:00',
          period: 'morning',
          plannedDose: dosage,
        ));
      }

      // Afternoon intake
      if (frequency.afternoon) {
        schedules.add(IntakeSchedule(
          date: date,
          time: '14:00',
          period: 'afternoon',
          plannedDose: dosage,
        ));
      }

      // Evening intake
      if (frequency.evening) {
        schedules.add(IntakeSchedule(
          date: date,
          time: '20:00',
          period: 'evening',
          plannedDose: dosage,
        ));
      }
    }

    return schedules;
  }

  /// Parse dosage string to extract numeric amount
  static int _parseDosageAmount(String dosage, MedicationType type) {
    // Try to extract number from dosage string
    final RegExp numberPattern = RegExp(r'(\d+(?:\.\d+)?)');
    final match = numberPattern.firstMatch(dosage);
    
    if (match != null) {
      final value = double.tryParse(match.group(1)!) ?? 0;
      return value.toInt();
    }

    // Default amounts based on type
    if (_isCountableType(type)) return 1;
    if (_isLiquidType(type)) return 5;
    
    return 1;
  }

  static bool _isCountableType(MedicationType type) {
    return type == MedicationType.tablet ||
        type == MedicationType.pill ||
        type == MedicationType.capsule ||
        type == MedicationType.suppository ||
        type == MedicationType.patch;
  }

  static bool _isLiquidType(MedicationType type) {
    return type == MedicationType.syrup ||
        type == MedicationType.oralDrops ||
        type == MedicationType.eyeDrops ||
        type == MedicationType.earDrops;
  }

  static List<int> _distributeWeekdays(int timesPerWeek) {
    if (timesPerWeek == 1) return [1]; // Monday
    if (timesPerWeek == 2) return [1, 4]; // Monday, Thursday
    if (timesPerWeek == 3) return [1, 3, 5]; // Monday, Wednesday, Friday
    if (timesPerWeek == 4) return [1, 2, 4, 5]; // Mon, Tue, Thu, Fri
    if (timesPerWeek == 5) return [1, 2, 3, 4, 5]; // Mon-Fri
    if (timesPerWeek == 6) return [1, 2, 3, 4, 5, 6]; // Mon-Sat
    return [1, 2, 3, 4, 5, 6, 7]; // Every day
  }

  static DateTime _findNextWeekday(DateTime from, int weekday) {
    final daysToAdd = (weekday - from.weekday + 7) % 7;
    return from.add(Duration(days: daysToAdd));
  }
}

/// Intake schedule structure
class IntakeSchedule {
  final DateTime date;
  final String time; // HH:mm format
  final String period; // morning, afternoon, evening
  final String plannedDose;

  const IntakeSchedule({
    required this.date,
    required this.time,
    required this.period,
    required this.plannedDose,
  });

  /// Generate intake ID in format: int_YYYYMMDD_period
  String generateId() {
    final dateStr = date.toIso8601String().split('T')[0].replaceAll('-', '');
    return 'int_${dateStr}_$period';
  }

  /// Convert to MedicationIntake
  MedicationIntake toIntake(String medicationId) {
    return MedicationIntake(
      id: generateId(),
      medicationId: medicationId,
      date: '${date.toIso8601String().split('T')[0]}T$time:00',
      taken: false,
      plannedTime: time,
      plannedDose: plannedDose,
      period: period,
    );
  }
}
