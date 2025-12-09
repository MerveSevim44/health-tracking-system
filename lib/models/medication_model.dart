import 'package:flutter/material.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/services/medication_service.dart';

// 📁 lib/models/medication_model.dart
// Provider model that wraps Firebase service

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

// Legacy UI model - kept for backwards compatibility
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

  // Convert from Firebase model
  factory Medication.fromFirebase(MedicationFirebase fb) {
    MedicationCategory category = MedicationCategory.morning;
    TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);
    Color color = const Color(0xFFFFD166);

    if (fb.frequency.morning) {
      category = MedicationCategory.morning;
      time = const TimeOfDay(hour: 8, minute: 0);
      color = const Color(0xFFFFD166);
    } else if (fb.frequency.afternoon) {
      category = MedicationCategory.afternoon;
      time = const TimeOfDay(hour: 14, minute: 0);
      color = const Color(0xFF06D6A0);
    } else if (fb.frequency.evening) {
      category = MedicationCategory.evening;
      time = const TimeOfDay(hour: 20, minute: 0);
      color = const Color(0xFF9D84FF);
    }

    return Medication(
      id: fb.id,
      name: fb.name,
      dosage: fb.dosage,
      category: category,
      time: time,
      icon: MedicationIcon.pill,
      color: color,
      isActive: fb.active,
    );
  }

  // Convert to Firebase model
  MedicationFirebase toFirebase() {
    return MedicationFirebase(
      id: id,
      name: name,
      dosage: dosage,
      instructions: '',
      startDate: DateTime.now().toIso8601String(),
      active: isActive,
      frequency: MedicationFrequency(
        morning: category == MedicationCategory.morning,
        afternoon: category == MedicationCategory.afternoon,
        evening: category == MedicationCategory.evening,
      ),
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
  final MedicationService _service = MedicationService();
  List<Medication> _medications = [];
  final List<MedicationLog> _logs = [];

  List<Medication> get medications => _medications;
  List<MedicationLog> get logs => _logs;

  // Listen to Firebase changes (call after user login)
  void initialize() {
    _service.getActiveMedications().listen((fbMeds) {
      _medications = fbMeds.map((fb) => Medication.fromFirebase(fb)).toList();
      notifyListeners();
    }, onError: (error) {
      // Handle errors silently if user not authenticated
      debugPrint('MedicationModel init error: $error');
    });
  }

  List<Medication> getMedicationsForCategory(MedicationCategory category) {
    return _medications
        .where((med) => med.category == category && med.isActive)
        .toList()
      ..sort((a, b) => _compareTimeOfDay(a.time, b.time));
  }

  List<Medication> getMedicationsForDay(DateTime day) {
    // Since we don't have scheduledDays in Firebase, return all active medications
    return _medications.where((med) => med.isActive).toList()
      ..sort((a, b) => _compareTimeOfDay(a.time, b.time));
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour.compareTo(b.hour);
    return a.minute.compareTo(b.minute);
  }

  Future<void> addMedication(Medication medication) async {
    await _service.addMedication(medication.toFirebase());
    notifyListeners();
  }

  Future<void> updateMedication(Medication medication) async {
    await _service.updateMedication(medication.toFirebase());
    notifyListeners();
  }

  Future<void> deleteMedication(String id) async {
    await _service.deleteMedication(id);
    notifyListeners();
  }

  Future<void> logMedicationAction(String medicationId, MedicationStatus status, {String? notes}) async {
    String takenStatus;
    switch (status) {
      case MedicationStatus.taken:
        takenStatus = 'take';
        break;
      case MedicationStatus.skipped:
        takenStatus = 'skip';
        break;
      case MedicationStatus.postponed:
        takenStatus = 'postpone';
        break;
    }

    await _service.logIntake(
      medicationId: medicationId,
      takenStatus: takenStatus,
      notes: notes ?? '',
    );

    notifyListeners();
  }

  Future<int> getTodayCompletionCount() async {
    return await _service.getTodayCompletionCount();
  }

  Future<int> getTodayTotalCount() async {
    return await _service.getTodayScheduledCount();
  }
}
