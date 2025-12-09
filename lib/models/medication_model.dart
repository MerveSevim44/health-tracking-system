import 'package:flutter/material.dart';

// 📁 lib/models/medication_model.dart

enum MedicationCategory {
  morning,
  afternoon,
  evening,
  night,
}

enum MedicationIcon {
  pill,
  capsule,
  bottle,
  vitamin,
  injection,
  drops,
  syrup,
}

enum MealTiming {
  beforeMeal,
  afterMeal,
  withMeal,
  anytime,
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final MedicationCategory category;
  final TimeOfDay time;
  final MedicationIcon icon;
  final MealTiming mealTiming;
  final Color color;
  final int pillsLeft;
  final int totalPills;
  final List<int> scheduledDays; // 0-6 for Sun-Sat
  final bool isActive;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.category,
    required this.time,
    required this.icon,
    this.mealTiming = MealTiming.anytime,
    required this.color,
    this.pillsLeft = 30,
    this.totalPills = 30,
    this.scheduledDays = const [0, 1, 2, 3, 4, 5, 6],
    this.isActive = true,
  });

  Medication copyWith({
    String? name,
    String? dosage,
    MedicationCategory? category,
    TimeOfDay? time,
    MedicationIcon? icon,
    MealTiming? mealTiming,
    Color? color,
    int? pillsLeft,
    int? totalPills,
    List<int>? scheduledDays,
    bool? isActive,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      category: category ?? this.category,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      mealTiming: mealTiming ?? this.mealTiming,
      color: color ?? this.color,
      pillsLeft: pillsLeft ?? this.pillsLeft,
      totalPills: totalPills ?? this.totalPills,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      isActive: isActive ?? this.isActive,
    );
  }
}

class MedicationLog {
  final String medicationId;
  final DateTime timestamp;
  final MedicationStatus status;
  final String? notes;

  MedicationLog({
    required this.medicationId,
    required this.timestamp,
    required this.status,
    this.notes,
  });
}

enum MedicationStatus {
  taken,
  skipped,
  postponed,
}

class MedicationModel extends ChangeNotifier {
  final List<Medication> _medications = [
    // Sample data
    Medication(
      id: '1',
      name: 'Vitamin C',
      dosage: '2 caps',
      category: MedicationCategory.morning,
      time: const TimeOfDay(hour: 8, minute: 0),
      icon: MedicationIcon.vitamin,
      color: const Color(0xFFFFD166),
      pillsLeft: 28,
      totalPills: 30,
    ),
    Medication(
      id: '2',
      name: 'Omega-3',
      dosage: '1 pill',
      category: MedicationCategory.morning,
      time: const TimeOfDay(hour: 9, minute: 0),
      icon: MedicationIcon.capsule,
      color: const Color(0xFF06D6A0),
      pillsLeft: 45,
      totalPills: 60,
    ),
    Medication(
      id: '3',
      name: 'Multivitamin',
      dosage: '1 tablet',
      category: MedicationCategory.afternoon,
      time: const TimeOfDay(hour: 14, minute: 0),
      icon: MedicationIcon.pill,
      color: const Color(0xFFFF6B6B),
      mealTiming: MealTiming.afterMeal,
      pillsLeft: 15,
      totalPills: 30,
    ),
    Medication(
      id: '4',
      name: 'Magnesium',
      dosage: '1 cap',
      category: MedicationCategory.evening,
      time: const TimeOfDay(hour: 20, minute: 0),
      icon: MedicationIcon.capsule,
      color: const Color(0xFF9D84FF),
      pillsLeft: 20,
      totalPills: 30,
    ),
  ];

  final List<MedicationLog> _logs = [];

  List<Medication> get medications => _medications;
  List<MedicationLog> get logs => _logs;

  List<Medication> getMedicationsForCategory(MedicationCategory category) {
    return _medications
        .where((med) => med.category == category && med.isActive)
        .toList()
      ..sort((a, b) => _compareTimeOfDay(a.time, b.time));
  }

  List<Medication> getMedicationsForDay(DateTime day) {
    final weekday = day.weekday % 7; // Convert to 0-6 (Sun-Sat)
    return _medications
        .where((med) => med.scheduledDays.contains(weekday) && med.isActive)
        .toList()
      ..sort((a, b) => _compareTimeOfDay(a.time, b.time));
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour.compareTo(b.hour);
    return a.minute.compareTo(b.minute);
  }

  void addMedication(Medication medication) {
    _medications.add(medication);
    notifyListeners();
  }

  void updateMedication(Medication medication) {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;
      notifyListeners();
    }
  }

  void deleteMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void logMedicationAction(String medicationId, MedicationStatus status, {String? notes}) {
    final log = MedicationLog(
      medicationId: medicationId,
      timestamp: DateTime.now(),
      status: status,
      notes: notes,
    );
    _logs.add(log);

    // Decrease pill count if taken
    if (status == MedicationStatus.taken) {
      final medIndex = _medications.indexWhere((m) => m.id == medicationId);
      if (medIndex != -1) {
        final med = _medications[medIndex];
        _medications[medIndex] = med.copyWith(
          pillsLeft: (med.pillsLeft - 1).clamp(0, med.totalPills),
        );
      }
    }

    notifyListeners();
  }

  int getTodayCompletionCount() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _logs
        .where((log) =>
            log.status == MedicationStatus.taken &&
            log.timestamp.isAfter(todayStart) &&
            log.timestamp.isBefore(todayEnd))
        .length;
  }

  int getTodayTotalCount() {
    return getMedicationsForDay(DateTime.now()).length;
  }
}
