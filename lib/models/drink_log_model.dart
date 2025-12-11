// 📁 lib/models/drink_log_model.dart
// Firebase model for non-water drinks (tea, coffee, juice, etc.)

/// Drink log entry for non-water beverages
/// Firebase path: drink_logs/{userId}/{logId}
class DrinkLogFirebase {
  final String id;
  final String type; // "tea", "coffee", "green tea", "matcha", etc.
  final int amount; // Always 200 ml (1 cup default)
  final String unit; // Always "ml"
  final int count; // Number of cups (default: 1)
  final String timestamp; // ISO string

  const DrinkLogFirebase({
    required this.id,
    required this.type,
    required this.amount,
    required this.unit,
    required this.count,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'unit': unit,
      'count': count,
      'timestamp': timestamp,
    };
  }

  factory DrinkLogFirebase.fromJson(String id, Map<String, dynamic> json) {
    return DrinkLogFirebase(
      id: id,
      type: json['type'] as String? ?? 'tea',
      amount: json['amount'] as int? ?? 200,
      unit: json['unit'] as String? ?? 'ml',
      count: json['count'] as int? ?? 1,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  DrinkLogFirebase copyWith({
    String? type,
    int? amount,
    String? unit,
    int? count,
    String? timestamp,
  }) {
    return DrinkLogFirebase(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      count: count ?? this.count,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// toDateKey() extension is already defined in water_firebase_model.dart
