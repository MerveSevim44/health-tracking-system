// 📁 lib/services/medication_service.dart
// Firebase service for medication management

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/services/notification_service.dart';

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
    
    // 🔔 Schedule notifications for this medication
    if (medication.active) {
      try {
        await NotificationService().scheduleAllMedicationNotifications();
        debugPrint('✅ [MedicationService] Notifications scheduled for new medication');
      } catch (e) {
        debugPrint('⚠️ [MedicationService] Failed to schedule notifications: $e');
      }
    }
    
    return ref.key!;
  }

  /// Update existing medication
  Future<void> updateMedication(MedicationFirebase medication) async {
    await _medicationsRef().child(medication.id).update(medication.toJson());
    
    // 🔔 Reschedule notifications after update
    try {
      if (medication.active) {
        await NotificationService().scheduleAllMedicationNotifications();
        debugPrint('✅ [MedicationService] Notifications rescheduled after medication update');
      } else {
        await NotificationService().cancelAllMedicationNotifications(medication.id);
        debugPrint('✅ [MedicationService] Notifications cancelled for inactive medication');
      }
    } catch (e) {
      debugPrint('⚠️ [MedicationService] Failed to update notifications: $e');
    }
  }

  /// Delete medication
  Future<void> deleteMedication(String medId) async {
    // 🔔 Cancel notifications before deleting medication
    try {
      await NotificationService().cancelAllMedicationNotifications(medId);
      debugPrint('✅ [MedicationService] Notifications cancelled for deleted medication');
    } catch (e) {
      debugPrint('⚠️ [MedicationService] Failed to cancel notifications: $e');
    }
    
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

  /// Toggle medication intake for a specific slot
  /// Path: medication_intakes/{uid}/{medId}/{YYYY-MM-DD}_{slot}
  Future<void> toggleIntake({
    required String medicationId,
    required DateTime date,
    required String slot, // 'morning' | 'afternoon' | 'evening'
    String notes = '',
  }) async {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final intakeKey = '${dateKey}_$slot';
    final ref = _intakesRef(medicationId).child(intakeKey);
    
    debugPrint('[TOGGLE INTAKE] Path: medication_intakes/$_userId/$medicationId/$intakeKey');
    
    // Check if intake exists
    final snapshot = await ref.get();
    
    if (snapshot.exists) {
      // Toggle existing
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final currentTaken = data['taken'] as bool? ?? false;
      final newTaken = !currentTaken;
      
      debugPrint('[TOGGLE INTAKE] Toggling from $currentTaken to $newTaken');
      
      await ref.update({
        'taken': newTaken,
        'takenAt': newTaken ? DateTime.now().millisecondsSinceEpoch : null,
      });
      
      // 🔔 Cancel notification if marked as taken
      if (newTaken) {
        try {
          await NotificationService().cancelMedicationNotification(medicationId, slot);
          debugPrint('✅ [MedicationService] Notification cancelled after marking as taken');
        } catch (e) {
          debugPrint('⚠️ [MedicationService] Failed to cancel notification: $e');
        }
      }
    } else {
      // Create new intake marked as taken
      debugPrint('[TOGGLE INTAKE] Creating new intake as taken');
      
      await ref.set({
        'date': dateKey,
        'period': slot,
        'taken': true,
        'takenAt': DateTime.now().millisecondsSinceEpoch,
        'notes': notes,
      });
      
      // 🔔 Cancel notification since it's marked as taken
      try {
        await NotificationService().cancelMedicationNotification(medicationId, slot);
        debugPrint('✅ [MedicationService] Notification cancelled after creating taken intake');
      } catch (e) {
        debugPrint('⚠️ [MedicationService] Failed to cancel notification: $e');
      }
    }
  }
  
  /// Log a medication intake (legacy support)
  Future<String> logIntake({
    required String medicationId,
    required String takenStatus, // "take" | "skip" | "postpone" - legacy support
    String notes = '',
    DateTime? date,
  }) async {
    // Convert legacy takenStatus to boolean
    final taken = takenStatus.toLowerCase() == 'take';
    
    final intake = MedicationIntake(
      id: '',
      medicationId: medicationId,
      date: (date ?? DateTime.now()).toIso8601String(),
      notes: notes,
      taken: taken,
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
    final today = DateTime.now();
    return getIntakesForDate(today);
  }

  /// Get intakes for a specific date across all medications
  Future<Map<String, List<MedicationIntake>>> getIntakesForDate(DateTime date) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    final snapshot = await _database.ref('medication_intakes/$_userId').get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return {};

    final Map<String, List<MedicationIntake>> result = {};

    for (var medEntry in data.entries) {
      final medId = medEntry.key as String;
      final intakes = medEntry.value as Map<dynamic, dynamic>;
      
      final dateIntakes = intakes.entries
          .map((e) => MedicationIntake.fromJson(
                e.key as String,
                medId,
                Map<String, dynamic>.from(e.value as Map),
              ))
          .where((intake) => intake.date.startsWith(dateKey))
          .toList();

      if (dateIntakes.isNotEmpty) {
        result[medId] = dateIntakes;
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
      count += list.where((intake) => intake.taken).length;
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

  // ==================== BULK INTAKE GENERATION ====================

  /// Generate and save multiple intakes at once
  /// Used when creating a new medication with automatic scheduling
  Future<void> generateIntakes({
    required String medicationId,
    required List<MedicationIntake> intakes,
  }) async {
    final ref = _intakesRef(medicationId);
    
    for (final intake in intakes) {
      // Use custom ID format: int_YYYYMMDD_period
      await ref.child(intake.id).set(intake.toJson());
    }
  }

  /// Update intake status (mark as taken/not taken)
  Future<void> updateIntakeStatus({
    required String medicationId,
    required String intakeId,
    required bool taken,
    String notes = '',
  }) async {
    await _intakesRef(medicationId).child(intakeId).update({
      'taken': taken,
      'notes': notes,
    });
  }

  /// Get intakes for a specific medication on a specific date
  Future<List<MedicationIntake>> getIntakesForMedicationOnDate({
    required String medicationId,
    required DateTime date,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final snapshot = await _intakesRef(medicationId).get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return [];

    return data.entries
        .map((e) => MedicationIntake.fromJson(
              e.key as String,
              medicationId,
              Map<String, dynamic>.from(e.value as Map),
            ))
        .where((intake) => intake.date.startsWith(dateStr))
        .toList();
  }

  /// Check if intakes exist for a medication
  Future<bool> hasIntakes(String medicationId) async {
    final snapshot = await _intakesRef(medicationId).get();
    return snapshot.exists && snapshot.value != null;
  }

  /// Delete all intakes for a medication
  Future<void> deleteAllIntakes(String medicationId) async {
    await _intakesRef(medicationId).remove();
  }
}
