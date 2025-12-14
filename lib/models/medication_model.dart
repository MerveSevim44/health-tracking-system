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
  final MedicationFrequency? frequencyOverride; // Override for multiple time selection

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
    this.frequencyOverride,
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
    MedicationFrequency? frequencyOverride,
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
      frequencyOverride: frequencyOverride ?? this.frequencyOverride,
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
      frequency: frequencyOverride ?? MedicationFrequency(
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
  List<MedicationFirebase> _medicationsFirebase = [];
  final List<MedicationLog> _logs = [];
  DateTime _selectedDate = DateTime.now();
  Map<String, List<MedicationIntake>> _selectedDateIntakes = {};

  List<Medication> get medications => _medications;
  List<MedicationFirebase> get medicationsFirebase => _medicationsFirebase;
  List<MedicationLog> get logs => _logs;
  DateTime get selectedDate => _selectedDate;
  Map<String, List<MedicationIntake>> get selectedDateIntakes => _selectedDateIntakes;

  // Listen to Firebase changes (call after user login)
  void initialize() {
    _service.getActiveMedications().listen((fbMeds) {
      _medicationsFirebase = fbMeds;
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
    // Seçili tarihteki alınan ilaçları filtrele
    final takenMedIds = _selectedDateIntakes.entries
        .where((entry) => entry.value.any((intake) => intake.taken))
        .map((entry) => entry.key)
        .toSet();
    
    // Aktif ve henüz alınmamış ilaçları döndür
    return _medications
        .where((med) => med.isActive && !takenMedIds.contains(med.id))
        .toList()
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

  Future<void> updateMedication(dynamic medication) async {
    if (medication is MedicationFirebase) {
      await _service.updateMedication(medication);
    } else if (medication is Medication) {
      await _service.updateMedication(medication.toFirebase());
    }
    notifyListeners();
  }

  Future<void> deleteMedication(String id) async {
    await _service.deleteMedication(id);
    notifyListeners();
  }

  Future<void> logMedicationAction(String medicationId, MedicationStatus status, {String? notes, DateTime? date}) async {
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
      date: date,
    );

    notifyListeners();
  }

  Future<int> getTodayCompletionCount() async {
    return await _service.getTodayCompletionCount();
  }

  Future<int> getTodayTotalCount() async {
    return await _service.getTodayScheduledCount();
  }

  // Seçili tarihi değiştir ve o tarihin intake'lerini yükle
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    await _loadIntakesForSelectedDate();
    notifyListeners();
  }

  // Seçili tarihin intake'lerini yükle
  Future<void> _loadIntakesForSelectedDate() async {
    try {
      _selectedDateIntakes = await _service.getIntakesForDate(_selectedDate);
    } catch (e) {
      debugPrint('Error loading intakes for date: $e');
      _selectedDateIntakes = {};
    }
  }

  // İlacı al ve intake'e kaydet, ardından listeden kaldırmak için refresh
  Future<void> takeMedication(String medicationId, DateTime date, {String? notes}) async {
    await logMedicationAction(medicationId, MedicationStatus.taken, notes: notes, date: date);
    // O tarihin intake'lerini yeniden yükle
    await setSelectedDate(date);
  }

  // Enhanced medication methods
  
  /// Add medication with full Firebase support (type, totalAmount, etc.)
  Future<String> addMedicationEnhanced(MedicationFirebase medication) async {
    final id = await _service.addMedication(medication);
    notifyListeners();
    return id;
  }

  /// Generate intakes for a medication
  Future<void> generateIntakes(String medicationId, List<MedicationIntake> intakes) async {
    await _service.generateIntakes(medicationId: medicationId, intakes: intakes);
    notifyListeners();
  }

  /// Get intakes for a specific medication on a specific date
  Future<List<MedicationIntake>> getIntakesForMedicationOnDate({
    required String medicationId,
    required DateTime date,
  }) async {
    return await _service.getIntakesForMedicationOnDate(
      medicationId: medicationId,
      date: date,
    );
  }

  /// Update intake status
  Future<void> updateIntakeStatus({
    required String medicationId,
    required String intakeId,
    required bool taken,
    String notes = '',
  }) async {
    await _service.updateIntakeStatus(
      medicationId: medicationId,
      intakeId: intakeId,
      taken: taken,
      notes: notes,
    );
    
    // Reload intakes for current date
    await _loadIntakesForSelectedDate();
    notifyListeners();
  }
  
  /// Toggle medication intake for a specific slot
  Future<void> toggleMedicationIntake({
    required String medicationId,
    required DateTime date,
    required String slot,
  }) async {
    await _service.toggleIntake(
      medicationId: medicationId,
      date: date,
      slot: slot,
    );
    
    // Reload intakes for current date
    await _loadIntakesForSelectedDate();
    notifyListeners();
  }
}
