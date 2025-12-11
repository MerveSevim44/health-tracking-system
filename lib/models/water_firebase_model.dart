// 📁 lib/models/water_firebase_model.dart
// Firebase-compatible water tracking models

/// Water log entry matching Firebase schema
/// Firebase path: water_logs/{userId}/{logId}
class WaterLogFirebase {
  final String id;
  final String drinkType; // "water" | "coffee" | "tea" | "matcha"
  final int amountML;
  final String createdAt; // ISO string
  final String date; // ISO string (date only for grouping)

  const WaterLogFirebase({
    required this.id,
    required this.drinkType,
    required this.amountML,
    required this.createdAt,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'drinkType': drinkType,
      'amountML': amountML,
      'createdAt': createdAt,
      'date': date,
    };
  }

  factory WaterLogFirebase.fromJson(String id, Map<String, dynamic> json) {
    // Safe parsing with backward compatibility
    // Handle both 'amountML' and 'amountMl' (case mismatch)
    int amount = 0;
    if (json.containsKey('amountML')) {
      amount = json['amountML'] as int? ?? 0;
    } else if (json.containsKey('amountMl')) {
      amount = json['amountMl'] as int? ?? 0;
    } else if (json.containsKey('amount')) {
      amount = json['amount'] as int? ?? 0;
    }
    
    return WaterLogFirebase(
      id: id,
      drinkType: json['drinkType'] as String? ?? 'water',
      amountML: amount,
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      date: json['date'] as String? ?? _getDateKey(DateTime.now()),
    );
  }

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  WaterLogFirebase copyWith({
    String? drinkType,
    int? amountML,
    String? createdAt,
    String? date,
  }) {
    return WaterLogFirebase(
      id: id,
      drinkType: drinkType ?? this.drinkType,
      amountML: amountML ?? this.amountML,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
    );
  }
}

/// Weekly water stats matching Firebase schema
/// Firebase path: weekly_stats/{userId}/water_current_week
class WeeklyWaterStats {
  final String weekStartDate; // ISO string
  final int totalAmountML;
  final String lastUpdate; // ISO string

  const WeeklyWaterStats({
    required this.weekStartDate,
    required this.totalAmountML,
    required this.lastUpdate,
  });

  Map<String, dynamic> toJson() {
    return {
      'weekStartDate': weekStartDate,
      'totalAmountML': totalAmountML,
      'lastUpdate': lastUpdate,
    };
  }

  factory WeeklyWaterStats.fromJson(Map<String, dynamic> json) {
    return WeeklyWaterStats(
      weekStartDate: json['weekStartDate'] as String? ?? DateTime.now().toIso8601String(),
      totalAmountML: json['totalAmountML'] as int? ?? 0,
      lastUpdate: json['lastUpdate'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  WeeklyWaterStats copyWith({
    String? weekStartDate,
    int? totalAmountML,
    String? lastUpdate,
  }) {
    return WeeklyWaterStats(
      weekStartDate: weekStartDate ?? this.weekStartDate,
      totalAmountML: totalAmountML ?? this.totalAmountML,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// Helper enum for drink types
enum DrinkTypeEnum {
  water,
  coffee,
  tea,
  matcha;

  static DrinkTypeEnum fromString(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return DrinkTypeEnum.water;
      case 'coffee':
        return DrinkTypeEnum.coffee;
      case 'tea':
        return DrinkTypeEnum.tea;
      case 'matcha':
        return DrinkTypeEnum.matcha;
      default:
        return DrinkTypeEnum.water;
    }
  }

  String get value {
    switch (this) {
      case DrinkTypeEnum.water:
        return 'water';
      case DrinkTypeEnum.coffee:
        return 'coffee';
      case DrinkTypeEnum.tea:
        return 'tea';
      case DrinkTypeEnum.matcha:
        return 'matcha';
    }
  }
}

/// Extension methods for date handling
extension WaterDateHelpers on DateTime {
  String toDateKey() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  DateTime get weekStart {
    return subtract(Duration(days: weekday - 1));
  }
}
