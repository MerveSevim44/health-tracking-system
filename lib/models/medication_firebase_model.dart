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

  const MedicationFirebase({
    required this.id,
    required this.name,
    required this.dosage,
    this.instructions = '',
    required this.startDate,
    this.active = true,
    required this.frequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'startDate': startDate,
      'active': active,
      'frequency': frequency.toJson(),
    };
  }

  factory MedicationFirebase.fromJson(String id, Map<String, dynamic> json) {
    return MedicationFirebase(
      id: id,
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      startDate: json['startDate'] as String? ?? DateTime.now().toIso8601String(),
      active: json['active'] as bool? ?? true,
      frequency: json['frequency'] != null
          ? MedicationFrequency.fromJson(json['frequency'] as Map<String, dynamic>)
          : const MedicationFrequency(),
    );
  }

  MedicationFirebase copyWith({
    String? name,
    String? dosage,
    String? instructions,
    String? startDate,
    bool? active,
    MedicationFrequency? frequency,
  }) {
    return MedicationFirebase(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      active: active ?? this.active,
      frequency: frequency ?? this.frequency,
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
  final String takenStatus; // "take" | "skip" | "postpone"

  const MedicationIntake({
    required this.id,
    required this.medicationId,
    required this.date,
    this.notes = '',
    required this.takenStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'notes': notes,
      'takenStatus': takenStatus,
    };
  }

  factory MedicationIntake.fromJson(String id, String medicationId, Map<String, dynamic> json) {
    return MedicationIntake(
      id: id,
      medicationId: medicationId,
      date: json['date'] as String? ?? DateTime.now().toIso8601String(),
      notes: json['notes'] as String? ?? '',
      takenStatus: json['takenStatus'] as String? ?? 'skip',
    );
  }

  MedicationIntake copyWith({
    String? date,
    String? notes,
    String? takenStatus,
  }) {
    return MedicationIntake(
      id: id,
      medicationId: medicationId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      takenStatus: takenStatus ?? this.takenStatus,
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

/// Helper to convert takenStatus string to enum-like values
enum TakenStatus {
  take,
  skip,
  postpone;

  static TakenStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'take':
        return TakenStatus.take;
      case 'skip':
        return TakenStatus.skip;
      case 'postpone':
        return TakenStatus.postpone;
      default:
        return TakenStatus.skip;
    }
  }

  String get value {
    switch (this) {
      case TakenStatus.take:
        return 'take';
      case TakenStatus.skip:
        return 'skip';
      case TakenStatus.postpone:
        return 'postpone';
    }
  }
}
