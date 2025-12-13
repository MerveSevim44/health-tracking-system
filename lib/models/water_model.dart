import 'package:flutter/material.dart';
import 'package:health_care/widgets/water/drink_selector.dart';
import 'package:health_care/services/water_service.dart';
import 'package:health_care/models/water_firebase_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Find matching drink type by name (case-insensitive)
    final drinkType = DrinkTypes.defaults.firstWhere(
      (d) => d.name.toLowerCase() == fb.drinkType.toLowerCase(),
      orElse: () => DrinkTypes.defaults[0], // Default to water if not found
    );

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
  void initialize([DateTime? date]) async {
    // Load daily goal from SharedPreferences
    await _loadDailyGoalFromLocal();
    
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

  // Load daily goal from SharedPreferences
  Future<void> _loadDailyGoalFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGoal = prefs.getInt('water_goal');
      if (savedGoal != null && savedGoal > 0) {
        _dailyGoal = savedGoal;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading daily goal from local storage: $e');
    }
  }

  // Sadece SU için günlük toplam ml (hedef için)
  int getCurrentIntake([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    final dateKey = _getDateKey(targetDate);
    final entries = _entriesByDate[dateKey] ?? [];
    // Sadece su için hesapla
    return entries
        .where((entry) => entry.drinkType.name.toLowerCase() == 'water')
        .fold(0, (sum, entry) => sum + entry.amount);
  }

  List<WaterIntakeEntry> getEntriesForDate([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    final dateKey = _getDateKey(targetDate);
    return List.from(_entriesByDate[dateKey] ?? []);
  }

  // Sadece SU için progress (hedef 2000ml su içindir)
  double getProgress([DateTime? date]) {
    final intake = getCurrentIntake(date);
    return (intake / _dailyGoal).clamp(0.0, 1.0);
  }

  // Su veya diğer içecek ekleme (su için ml, diğerleri için 1 bardak=200ml)
  Future<void> addWaterIntake(DrinkType? drinkType, int amount) async {
    final drinkTypeString = drinkType?.name.toLowerCase() ?? 'water';
    
    // Su mu kontrol et
    final isWater = drinkTypeString == 'water';
    
    if (isWater) {
      // Su ise: kullanıcının girdiği ml değerini kaydet
      await _service.addWaterLog(
        drinkType: drinkTypeString,
        amountML: amount,
      );
      // Update weekly stats (sadece su için)
      await _service.updateWeeklyStats();
    }
    // Diğer içecekler için: DrinkProvider kullanılacak, burada işlem yapma
    
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

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_goal', goal);
    } catch (e) {
      debugPrint('Error saving daily goal to local storage: $e');
    }
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

  // İçeceğin su olup olmadığını kontrol et
  bool isWaterDrink(DrinkType drinkType) {
    return drinkType.name.toLowerCase() == 'water';
  }

  // Bugün eklenen diğer içecek sayısını getir
  Future<int> getTodayDrinkCount([DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    return await _service.getDrinkCountForDate(targetDate);
  }

  void clearAllData() {
    _entriesByDate.clear();
    notifyListeners();
  }

  // ==================== NEW ADVANCED FEATURES ====================

  /// Add water intake with string drink type (for compatibility)
  Future<void> addWaterIntakeByType(String drinkTypeId, int amount) async {
    final drinkTypeString = drinkTypeId.toLowerCase();
    
    await _service.addWaterLog(
      drinkType: drinkTypeString,
      amountML: amount,
    );

    // Update weekly stats
    await _service.updateWeeklyStats();
    
    notifyListeners();
  }

  /// Get today's drink breakdown
  /// Returns map like: { "water": 850, "green tea": 300 }
  Future<Map<String, int>> getTodayDrinkBreakdown() async {
    return await _service.getDrinkDistribution(DateTime.now());
  }

  /// Get total for today with hydration factor applied
  /// This accounts for different hydration effectiveness of drinks
  Future<double> getEffectiveHydration(DateTime date) async {
    final breakdown = await _service.getDrinkDistribution(date);
    // This would require importing drink_type_info.dart
    // For now, return regular total
    final total = breakdown.values.fold(0, (sum, amount) => sum + amount);
    return total.toDouble();
  }
}
