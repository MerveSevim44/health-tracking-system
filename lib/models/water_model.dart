import 'package:flutter/material.dart';
import 'package:health_care/widgets/water/drink_selector.dart';
import 'package:health_care/services/water_service.dart';
import 'package:health_care/models/water_firebase_model.dart';

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

  // Convert from Firebase model
  factory WaterIntakeEntry.fromFirebase(WaterLogFirebase fb) {
    // Map drinkType string to DrinkType object
    DrinkType drinkType;
    switch (fb.drinkType.toLowerCase()) {
      case 'water':
        drinkType = DrinkTypes.defaults[0];
        break;
      case 'coffee':
        drinkType = DrinkTypes.defaults[1];
        break;
      case 'tea':
        drinkType = DrinkTypes.defaults[2];
        break;
      case 'matcha':
        drinkType = DrinkTypes.defaults[3];
        break;
      default:
        drinkType = DrinkTypes.defaults[0];
    }

    return WaterIntakeEntry(
      drinkType: drinkType,
      amount: fb.amountML,
      timestamp: DateTime.parse(fb.createdAt),
    );
  }
}

class WaterModel extends ChangeNotifier {
  final WaterService _service = WaterService();
  int _dailyGoal = 2000; // Default goal in ml
  final Map<String, List<WaterIntakeEntry>> _entriesByDate = {};

  int get dailyGoal => _dailyGoal;
  
  // Initialize Firebase listener (call after user login)
  void initialize([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    _service.getWaterLogsForDate(targetDate).listen((logs) {
      final dateKey = _getDateKey(targetDate);
      _entriesByDate[dateKey] = logs.map((log) => 
        WaterIntakeEntry.fromFirebase(log)
      ).toList();
      notifyListeners();
    }, onError: (error) {
      // Handle errors silently if user not authenticated
      debugPrint('WaterModel init error: $error');
    });
  }

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

  Future<void> addWaterIntake(DrinkType drinkType, int amount) async {
    // Map DrinkType to string for Firebase
    String drinkTypeString;
    switch (drinkType.name.toLowerCase()) {
      case 'water':
        drinkTypeString = 'water';
        break;
      case 'coffee':
        drinkTypeString = 'coffee';
        break;
      case 'tea':
        drinkTypeString = 'tea';
        break;
      case 'matcha':
        drinkTypeString = 'matcha';
        break;
      default:
        drinkTypeString = 'water';
    }

    await _service.addWaterLog(
      drinkType: drinkTypeString,
      amountML: amount,
    );

    // Update weekly stats
    await _service.updateWeeklyStats();
    
    notifyListeners();
  }

  Future<void> removeEntry(DateTime date, int index) async {
    final dateKey = _getDateKey(date);
    if (_entriesByDate.containsKey(dateKey) && 
        index < _entriesByDate[dateKey]!.length) {
      // Get the entry to find its Firebase ID
      // Note: This requires storing the Firebase ID in WaterIntakeEntry
      // For now, we'll just remove from local cache
      _entriesByDate[dateKey]!.removeAt(index);
      notifyListeners();
    }
  }

  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    notifyListeners();
  }

  Future<bool> isGoalAchieved([DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    return await _service.isGoalAchieved(targetDate, _dailyGoal);
  }

  Future<Map<String, int>> getDrinkDistribution([DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    return await _service.getDrinkDistribution(targetDate);
  }

  // Weekly statistics
  Future<int> getWeeklyIntake() async {
    final weeklyStats = await _service.getWeeklyStats().first;
    return weeklyStats.totalAmountML;
  }

  Future<List<int>> getWeeklyData() async {
    return await _service.getWeeklyData();
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void clearAllData() {
    _entriesByDate.clear();
    notifyListeners();
  }
}
