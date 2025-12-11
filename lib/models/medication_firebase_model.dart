// 📁 lib/models/medication_firebase_model.dart
// Firebase-compatible medication models

import 'package:flutter/material.dart';

/// Medication frequency structure matching Firebase schema
class MedicationFrequency {
  final bool morning;
  final bool afternoon;
  final bool evening;

  const MedicationFrequency({
    this.morning = false,
    this.afternoon = false,
    this.evening = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
    };
  }

  factory MedicationFrequency.fromJson(Map<String, dynamic> json) {
    return MedicationFrequency(
      morning: json['morning'] as bool? ?? false,
      afternoon: json['afternoon'] as bool? ?? false,
      evening: json['evening'] as bool? ?? false,
    );
  }

  MedicationFrequency copyWith({
    bool? morning,
    bool? afternoon,
    bool? evening,
  }) {
    return MedicationFrequency(
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      evening: evening ?? this.evening,
    );
  }
}

/// Main medication model matching Firebase schema
/// Firebase path: medications/{userId}/{medId}
class MedicationFirebase {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final String startDate; // ISO string
  final bool active;
  final MedicationFrequency frequency;
  final String? type; // Medication type (tablet, syrup, etc.)
  final int? totalAmount; // Total amount of medication (pills, ml, etc.)
  final String? endDate; // Calculated or manual end date

  const MedicationFirebase({
    required this.id,
    required this.name,
    required this.dosage,
    this.instructions = '',
    required this.startDate,
    this.active = true,
    required this.frequency,
    this.type,
    this.totalAmount,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'startDate': startDate,
      'active': active,
      'frequency': frequency.toJson(),
    };
    
    if (type != null) json['type'] = type!;
    if (totalAmount != null) json['totalAmount'] = totalAmount!;
    if (endDate != null) json['endDate'] = endDate!;
    
    return json;
  }

  factory MedicationFirebase.fromJson(String id, Map<String, dynamic> json) {
    // Parse frequency field safely - handle both object and string formats
    MedicationFrequency frequency;
    
    if (json['frequency'] == null) {
      // No frequency data - use default (all false)
      frequency = const MedicationFrequency();
    } else if (json['frequency'] is Map) {
      // New format: frequency is an object
      frequency = MedicationFrequency.fromJson(
        Map<String, dynamic>.from(json['frequency'] as Map)
      );
    } else if (json['frequency'] is String) {
      // Old format: frequency is a string - convert to object
      final freqString = (json['frequency'] as String).toLowerCase();
      frequency = MedicationFrequency(
        morning: freqString.contains('morning') || freqString.contains('sabah'),
        afternoon: freqString.contains('afternoon') || freqString.contains('öğle'),
        evening: freqString.contains('evening') || freqString.contains('akşam'),
      );
    } else {
      // Unknown format - use default
      frequency = const MedicationFrequency();
    }
    
    return MedicationFirebase(
      id: id,
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      startDate: json['startDate'] as String? ?? DateTime.now().toIso8601String(),
      active: json['active'] as bool? ?? true,
      frequency: frequency,
      type: json['type'] as String?,
      totalAmount: json['totalAmount'] as int?,
      endDate: json['endDate'] as String?,
    );
  }

  MedicationFirebase copyWith({
    String? name,
    String? dosage,
    String? instructions,
    String? startDate,
    bool? active,
    MedicationFrequency? frequency,
    String? type,
    int? totalAmount,
    String? endDate,
  }) {
    return MedicationFirebase(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      active: active ?? this.active,
      frequency: frequency ?? this.frequency,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Helper to check if medication is scheduled for a specific time
  bool isScheduledFor(String period) {
    switch (period.toLowerCase()) {
      case 'morning':
        return frequency.morning;
      case 'afternoon':
        return frequency.afternoon;
      case 'evening':
        return frequency.evening;
      default:
        return false;
    }
  }
}

/// Medication intake log matching Firebase schema
/// Firebase path: medication_intakes/{userId}/{medId}/{intakeId}
class MedicationIntake {
  final String id;
  final String medicationId;
  final String date; // ISO string
  final String notes;
  final bool taken; // true if taken, false if not
  final String? plannedTime; // HH:mm format
  final String? plannedDose; // e.g., "1 pill", "5 ml"
  final String? period; // 'morning', 'afternoon', or 'evening'

  const MedicationIntake({
    required this.id,
    required this.medicationId,
    required this.date,
    this.notes = '',
    required this.taken,
    this.plannedTime,
    this.plannedDose,
    this.period,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'date': date,
      'notes': notes,
      'taken': taken,
    };
    
    if (plannedTime != null) json['plannedTime'] = plannedTime!;
    if (plannedDose != null) json['plannedDose'] = plannedDose!;
    if (period != null) json['period'] = period!;
    
    return json;
  }

  factory MedicationIntake.fromJson(String id, String medicationId, Map<String, dynamic> json) {
    // Support legacy takenStatus field
    bool taken = false;
    if (json.containsKey('taken')) {
      taken = json['taken'] as bool? ?? false;
    } else if (json.containsKey('takenStatus')) {
      taken = json['takenStatus'] == 'take';
    }
    
    return MedicationIntake(
      id: id,
      medicationId: medicationId,
      date: json['date'] as String? ?? DateTime.now().toIso8601String(),
      notes: json['notes'] as String? ?? '',
      taken: taken,
      plannedTime: json['plannedTime'] as String?,
      plannedDose: json['plannedDose'] as String?,
      period: json['period'] as String?,
    );
  }

  MedicationIntake copyWith({
    String? date,
    String? notes,
    bool? taken,
    String? plannedTime,
    String? plannedDose,
    String? period,
  }) {
    return MedicationIntake(
      id: id,
      medicationId: medicationId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      taken: taken ?? this.taken,
      plannedTime: plannedTime ?? this.plannedTime,
      plannedDose: plannedDose ?? this.plannedDose,
      period: period ?? this.period,
    );
  }
}

/// Extension for backwards compatibility with UI
extension MedicationFirebaseUI on MedicationFirebase {
  Color get displayColor {
    if (frequency.morning) return const Color(0xFFFFD166);
    if (frequency.afternoon) return const Color(0xFF06D6A0);
    if (frequency.evening) return const Color(0xFF9D84FF);
    return const Color(0xFF4FC3F7);
  }

  IconData get displayIcon => Icons.medication;

  String get displayTime {
    if (frequency.morning) return '08:00';
    if (frequency.afternoon) return '14:00';
    if (frequency.evening) return '20:00';
    return '09:00';
  }
}


