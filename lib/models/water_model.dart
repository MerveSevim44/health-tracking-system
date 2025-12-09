import 'package:flutter/material.dart';
import 'package:health_care/widgets/water/drink_selector.dart';

class WaterIntakeEntry {
  final DrinkType drinkType;
  final int amount; // in ml
  final DateTime timestamp;

  WaterIntakeEntry({
    required this.drinkType,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'drinkName': drinkType.name,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WaterIntakeEntry.fromJson(Map<String, dynamic> json) {
    // Find matching drink type
    final drinkType = DrinkTypes.defaults.firstWhere(
      (d) => d.name == json['drinkName'],
      orElse: () => DrinkTypes.defaults[0],
    );

    return WaterIntakeEntry(
      drinkType: drinkType,
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class WaterModel extends ChangeNotifier {
  int _dailyGoal = 2000; // Default goal in ml
  final Map<String, List<WaterIntakeEntry>> _entriesByDate = {};

  int get dailyGoal => _dailyGoal;
  
  int getCurrentIntake([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    final dateKey = _getDateKey(targetDate);
    final entries = _entriesByDate[dateKey] ?? [];
    return entries.fold(0, (sum, entry) => sum + entry.amount);
  }

  List<WaterIntakeEntry> getEntriesForDate([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    final dateKey = _getDateKey(targetDate);
    return List.from(_entriesByDate[dateKey] ?? []);
  }

  double getProgress([DateTime? date]) {
    final intake = getCurrentIntake(date);
    return (intake / _dailyGoal).clamp(0.0, 1.0);
  }

  void addWaterIntake(DrinkType drinkType, int amount) {
    final now = DateTime.now();
    final dateKey = _getDateKey(now);
    
    _entriesByDate.putIfAbsent(dateKey, () => []);
    _entriesByDate[dateKey]!.add(
      WaterIntakeEntry(
        drinkType: drinkType,
        amount: amount,
        timestamp: now,
      ),
    );
    
    notifyListeners();
  }

  void removeEntry(DateTime date, int index) {
    final dateKey = _getDateKey(date);
    if (_entriesByDate.containsKey(dateKey)) {
      _entriesByDate[dateKey]!.removeAt(index);
      notifyListeners();
    }
  }

  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    notifyListeners();
  }

  bool isGoalAchieved([DateTime? date]) {
    return getCurrentIntake(date) >= _dailyGoal;
  }

  Map<String, int> getDrinkDistribution([DateTime? date]) {
    final entries = getEntriesForDate(date);
    final distribution = <String, int>{};
    
    for (var entry in entries) {
      distribution[entry.drinkType.name] = 
          (distribution[entry.drinkType.name] ?? 0) + entry.amount;
    }
    
    return distribution;
  }

  // Weekly statistics
  int getWeeklyIntake() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int total = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      total += getCurrentIntake(date);
    }
    
    return total;
  }

  List<int> getWeeklyData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = <int>[];
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      weeklyData.add(getCurrentIntake(date));
    }
    
    return weeklyData;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void clearAllData() {
    _entriesByDate.clear();
    notifyListeners();
  }
}
