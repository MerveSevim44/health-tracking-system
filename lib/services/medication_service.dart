// 📁 lib/services/medication_service.dart
// Firebase service for medication management

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_care/models/medication_firebase_model.dart';

class MedicationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  String? get _userId => _auth.currentUser?.uid;

  // ==================== MEDICATIONS ====================

  /// Get reference to medications path
  DatabaseReference _medicationsRef() {
    if (_userId == null) throw Exception('User not authenticated');
    return _database.ref('medications/$_userId');
  }

  /// Add a new medication
  Future<String> addMedication(MedicationFirebase medication) async {
    final ref = _medicationsRef().push();
    await ref.set(medication.toJson());
    return ref.key!;
  }

  /// Update existing medication
  Future<void> updateMedication(MedicationFirebase medication) async {
    await _medicationsRef().child(medication.id).update(medication.toJson());
  }

  /// Delete medication
  Future<void> deleteMedication(String medId) async {
    await _medicationsRef().child(medId).remove();
  }

  /// Get all medications for current user
  Stream<List<MedicationFirebase>> getMedications() {
    return _medicationsRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <MedicationFirebase>[];

      return data.entries.map((entry) {
        return MedicationFirebase.fromJson(
          entry.key as String,
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();
    });
  }

  /// Get medications filtered by active status
  Stream<List<MedicationFirebase>> getActiveMedications() {
    return getMedications().map((meds) => 
      meds.where((med) => med.active).toList()
    );
  }

  /// Get medications scheduled for specific time period
  Stream<List<MedicationFirebase>> getMedicationsForPeriod(String period) {
    return getActiveMedications().map((meds) => 
      meds.where((med) => med.isScheduledFor(period)).toList()
    );
  }

  // ==================== MEDICATION INTAKES ====================

  /// Get reference to medication intakes path
  DatabaseReference _intakesRef(String medId) {
    if (_userId == null) throw Exception('User not authenticated');
    return _database.ref('medication_intakes/$_userId/$medId');
  }

  /// Log a medication intake
  Future<String> logIntake({
    required String medicationId,
    required String takenStatus, // "take" | "skip" | "postpone"
    String notes = '',
  }) async {
    final intake = MedicationIntake(
      id: '',
      medicationId: medicationId,
      date: DateTime.now().toIso8601String(),
      notes: notes,
      takenStatus: takenStatus,
    );

    final ref = _intakesRef(medicationId).push();
    await ref.set(intake.toJson());
    return ref.key!;
  }

  /// Get all intakes for a specific medication
  Stream<List<MedicationIntake>> getIntakesForMedication(String medId) {
    return _intakesRef(medId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <MedicationIntake>[];

      return data.entries.map((entry) {
        return MedicationIntake.fromJson(
          entry.key as String,
          medId,
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();
    });
  }

  /// Get intakes for today across all medications
  Future<Map<String, List<MedicationIntake>>> getTodayIntakes() async {
    if (_userId == null) throw Exception('User not authenticated');
    
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final snapshot = await _database.ref('medication_intakes/$_userId').get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return {};

    final Map<String, List<MedicationIntake>> result = {};

    for (var medEntry in data.entries) {
      final medId = medEntry.key as String;
      final intakes = medEntry.value as Map<dynamic, dynamic>;
      
      final todayIntakes = intakes.entries
          .map((e) => MedicationIntake.fromJson(
                e.key as String,
                medId,
                Map<String, dynamic>.from(e.value as Map),
              ))
          .where((intake) => intake.date.startsWith(todayKey))
          .toList();

      if (todayIntakes.isNotEmpty) {
        result[medId] = todayIntakes;
      }
    }

    return result;
  }

  /// Update an existing intake
  Future<void> updateIntake({
    required String medicationId,
    required String intakeId,
    required MedicationIntake intake,
  }) async {
    await _intakesRef(medicationId).child(intakeId).update(intake.toJson());
  }

  /// Delete an intake
  Future<void> deleteIntake({
    required String medicationId,
    required String intakeId,
  }) async {
    await _intakesRef(medicationId).child(intakeId).remove();
  }

  // ==================== STATISTICS ====================

  /// Get completion count for today
  Future<int> getTodayCompletionCount() async {
    final intakes = await getTodayIntakes();
    int count = 0;
    
    for (var list in intakes.values) {
      count += list.where((intake) => intake.takenStatus == 'take').length;
    }
    
    return count;
  }

  /// Get total scheduled medications for today
  Future<int> getTodayScheduledCount() async {
    final snapshot = await _medicationsRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return 0;

    return data.values
        .where((med) => (med as Map)['active'] == true)
        .length;
  }
}
