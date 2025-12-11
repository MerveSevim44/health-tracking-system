// 📁 lib/models/medication_type_config.dart
// Medication type definitions with automatic dosage suggestions

import 'package:flutter/material.dart';

/// Medication type enumeration
enum MedicationType {
  tablet,
  pill,
  capsule,
  syrup,
  injection,
  oralDrops,
  spray,
  eyeDrops,
  earDrops,
  cream,
  ointment,
  suppository,
  inhaler,
  patch,
}

/// Extension for medication type properties
extension MedicationTypeExtension on MedicationType {
  /// Display name in Turkish
  String get displayName {
    switch (this) {
      case MedicationType.tablet:
        return 'Tablet';
      case MedicationType.pill:
        return 'Hap';
      case MedicationType.capsule:
        return 'Kapsül';
      case MedicationType.syrup:
        return 'Şurup';
      case MedicationType.injection:
        return 'İğne (IM/SC/IV)';
      case MedicationType.oralDrops:
        return 'Oral Damla';
      case MedicationType.spray:
        return 'Sprey';
      case MedicationType.eyeDrops:
        return 'Göz Damlası';
      case MedicationType.earDrops:
        return 'Kulak Damlası';
      case MedicationType.cream:
        return 'Krem';
      case MedicationType.ointment:
        return 'Merhem';
      case MedicationType.suppository:
        return 'Fitil';
      case MedicationType.inhaler:
        return 'İnhaler';
      case MedicationType.patch:
        return 'Patch';
    }
  }

  /// Icon for each medication type
  IconData get icon {
    switch (this) {
      case MedicationType.tablet:
      case MedicationType.pill:
        return Icons.medication;
      case MedicationType.capsule:
        return Icons.medical_services_outlined;
      case MedicationType.syrup:
        return Icons.local_drink;
      case MedicationType.injection:
        return Icons.vaccines;
      case MedicationType.oralDrops:
      case MedicationType.eyeDrops:
      case MedicationType.earDrops:
        return Icons.water_drop;
      case MedicationType.spray:
        return Icons.air;
      case MedicationType.cream:
      case MedicationType.ointment:
        return Icons.wash;
      case MedicationType.suppository:
        return Icons.expand_less;
      case MedicationType.inhaler:
        return Icons.wind_power;
      case MedicationType.patch:
        return Icons.square;
    }
  }

  /// Default dosage suggestion
  String get defaultDosage {
    switch (this) {
      case MedicationType.tablet:
      case MedicationType.pill:
        return '1 tablet';
      case MedicationType.capsule:
        return '1 capsule';
      case MedicationType.syrup:
        return '5 ml';
      case MedicationType.injection:
        return '1 dose';
      case MedicationType.oralDrops:
        return '5 drops';
      case MedicationType.spray:
        return '1 spray';
      case MedicationType.eyeDrops:
      case MedicationType.earDrops:
        return '2 drops';
      case MedicationType.cream:
      case MedicationType.ointment:
        return 'Apply thin layer';
      case MedicationType.suppository:
        return '1 suppository';
      case MedicationType.inhaler:
        return '1 puff';
      case MedicationType.patch:
        return '1 patch';
    }
  }

  /// Usage instructions in Turkish
  String get usageInstructions {
    switch (this) {
      case MedicationType.tablet:
      case MedicationType.pill:
      case MedicationType.capsule:
        return 'Su ile yutulur';
      case MedicationType.syrup:
        return '5-10 ml içilir';
      case MedicationType.injection:
        return 'Kas/deri altı/damar yoluyla';
      case MedicationType.oralDrops:
        return 'Suya damlatılır';
      case MedicationType.spray:
        return 'Burun/ağız içine sıkılır';
      case MedicationType.eyeDrops:
        return 'Göze damlatılır';
      case MedicationType.earDrops:
        return 'Kulağa damlatılır';
      case MedicationType.cream:
      case MedicationType.ointment:
        return 'İnce tabaka halinde sürülür';
      case MedicationType.suppository:
        return 'Genital bölgelere uygulanır';
      case MedicationType.inhaler:
        return 'Ağızdan nefes ile alınır';
      case MedicationType.patch:
        return 'Cilde yapıştırılır';
    }
  }

  /// Recommended frequency configuration
  MedicationFrequencyRecommendation get recommendedFrequency {
    switch (this) {
      case MedicationType.tablet:
      case MedicationType.pill:
      case MedicationType.capsule:
        return MedicationFrequencyRecommendation(
          morning: true,
          afternoon: false,
          evening: true,
          timesPerDay: 2,
          description: '1-2 kez/gün',
        );
      case MedicationType.syrup:
        return MedicationFrequencyRecommendation(
          morning: true,
          afternoon: true,
          evening: true,
          timesPerDay: 3,
          description: '2-3 kez/gün',
        );
      case MedicationType.injection:
        return MedicationFrequencyRecommendation(
          morning: true,
          afternoon: false,
          evening: false,
          timesPerDay: 1,
          description: 'Tek doz veya düzenli',
        );
      case MedicationType.spray:
        return MedicationFrequencyRecommendation(
          morning: true,
          afternoon: true,
          evening: false,
          timesPerDay: 2,
          description: '2-3 kez/gün',
        );
      case MedicationType.eyeDrops:
      case MedicationType.earDrops:
        return MedicationFrequencyRecommendation(
          morning: true,
          afternoon: true,
          evening: true,
          timesPerDay: 3,
          description: '2-4 kez/gün',
        );
      case MedicationType.cream:
      case MedicationType.ointment:
        return MedicationFrequencyRecommendation(
          morning: true,
          afternoon: false,
          evening: true,
          timesPerDay: 2,
          description: '1-2 kez/gün',
        );
      case MedicationType.suppository:
        return MedicationFrequencyRecommendation(
          morning: false,
          afternoon: false,
          evening: true,
          timesPerDay: 1,
          description: '1 kez/gün',
        );
      case MedicationType.inhaler:
        return MedicationFrequencyRecommendation(
          morning: true,
          afternoon: true,
          evening: false,
          timesPerDay: 2,
          description: 'İlaca göre değişir',
        );
      case MedicationType.patch:
        return MedicationFrequencyRecommendation(
          morning: true,
          afternoon: false,
          evening: false,
          timesPerDay: 1,
          description: '24-72 saat',
        );
      case MedicationType.oralDrops:
        return MedicationFrequencyRecommendation(
          morning: true,
          afternoon: false,
          evening: true,
          timesPerDay: 2,
          description: 'İlaca göre değişir',
        );
    }
  }

  /// Color associated with medication type
  Color get color {
    switch (this) {
      case MedicationType.tablet:
      case MedicationType.pill:
        return const Color(0xFFFFD166);
      case MedicationType.capsule:
        return const Color(0xFF06D6A0);
      case MedicationType.syrup:
        return const Color(0xFF9D84FF);
      case MedicationType.injection:
        return const Color(0xFFFF6B6B);
      case MedicationType.oralDrops:
      case MedicationType.eyeDrops:
      case MedicationType.earDrops:
        return const Color(0xFF4FC3F7);
      case MedicationType.spray:
        return const Color(0xFFCE93D8);
      case MedicationType.cream:
      case MedicationType.ointment:
        return const Color(0xFFA5D6A7);
      case MedicationType.suppository:
        return const Color(0xFFFFCC80);
      case MedicationType.inhaler:
        return const Color(0xFFB0BEC5);
      case MedicationType.patch:
        return const Color(0xFFD4A373);
    }
  }

  /// Convert to string for Firebase
  String toFirebaseValue() {
    return toString().split('.').last;
  }

  /// Parse from Firebase string
  static MedicationType? fromFirebaseValue(String? value) {
    if (value == null) return null;
    try {
      return MedicationType.values.firstWhere(
        (type) => type.toFirebaseValue() == value,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Frequency recommendation structure
class MedicationFrequencyRecommendation {
  final bool morning;
  final bool afternoon;
  final bool evening;
  final int timesPerDay;
  final String description;

  const MedicationFrequencyRecommendation({
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.timesPerDay,
    required this.description,
  });
}

/// Dosage unit types
enum DosageUnit {
  tablet,
  capsule,
  ml,
  drops,
  spray,
  puff,
  patch,
  application,
  suppository,
  mg,
  g,
}

extension DosageUnitExtension on DosageUnit {
  String get displayName {
    switch (this) {
      case DosageUnit.tablet:
        return 'tablet';
      case DosageUnit.capsule:
        return 'capsule';
      case DosageUnit.ml:
        return 'ml';
      case DosageUnit.drops:
        return 'drops';
      case DosageUnit.spray:
        return 'spray';
      case DosageUnit.puff:
        return 'puff';
      case DosageUnit.patch:
        return 'patch';
      case DosageUnit.application:
        return 'application';
      case DosageUnit.suppository:
        return 'suppository';
      case DosageUnit.mg:
        return 'mg';
      case DosageUnit.g:
        return 'g';
    }
  }

  String get displayNameTurkish {
    switch (this) {
      case DosageUnit.tablet:
        return 'tablet';
      case DosageUnit.capsule:
        return 'kapsül';
      case DosageUnit.ml:
        return 'ml';
      case DosageUnit.drops:
        return 'damla';
      case DosageUnit.spray:
        return 'sıkma';
      case DosageUnit.puff:
        return 'puf';
      case DosageUnit.patch:
        return 'patch';
      case DosageUnit.application:
        return 'uygulama';
      case DosageUnit.suppository:
        return 'fitil';
      case DosageUnit.mg:
        return 'mg';
      case DosageUnit.g:
        return 'g';
    }
  }
}
