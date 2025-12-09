// 📁 lib/services/water_service.dart
// Firebase service for water tracking

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_care/models/water_firebase_model.dart';

class WaterService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  String? get _userId => _auth.currentUser?.uid;

  // ==================== WATER LOGS ====================

  /// Get reference to water logs path
  DatabaseReference _waterLogsRef() {
    if (_userId == null) throw Exception('User not authenticated');
    return _database.ref('water_logs/$_userId');
  }

  /// Add a water log entry
  Future<String> addWaterLog({
    required String drinkType, // "water" | "coffee" | "tea" | "matcha"
    required int amountML,
  }) async {
    final now = DateTime.now();
    final log = WaterLogFirebase(
      id: '',
      drinkType: drinkType,
      amountML: amountML,
      createdAt: now.toIso8601String(),
      date: now.toDateKey(),
    );

    final ref = _waterLogsRef().push();
    await ref.set(log.toJson());
    return ref.key!;
  }

  /// Get all water logs
  Stream<List<WaterLogFirebase>> getWaterLogs() {
    return _waterLogsRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <WaterLogFirebase>[];

      return data.entries.map((entry) {
        return WaterLogFirebase.fromJson(
          entry.key as String,
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();
    });
  }

  /// Get water logs for a specific date
  Stream<List<WaterLogFirebase>> getWaterLogsForDate(DateTime date) {
    final dateKey = date.toDateKey();
    return getWaterLogs().map((logs) => 
      logs.where((log) => log.date == dateKey).toList()
    );
  }

  /// Get total intake for a specific date
  Future<int> getTotalIntakeForDate(DateTime date) async {
    final dateKey = date.toDateKey();
    final snapshot = await _waterLogsRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return 0;

    int total = 0;
    for (var entry in data.values) {
      final log = entry as Map;
      if (log['date'] == dateKey) {
        total += (log['amountML'] as int?) ?? 0;
      }
    }

    return total;
  }

  /// Get drink distribution for a specific date
  Future<Map<String, int>> getDrinkDistribution(DateTime date) async {
    final dateKey = date.toDateKey();
    final snapshot = await _waterLogsRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return {};

    final Map<String, int> distribution = {};

    for (var entry in data.values) {
      final log = entry as Map;
      if (log['date'] == dateKey) {
        final drinkType = log['drinkType'] as String? ?? 'water';
        final amount = (log['amountML'] as int?) ?? 0;
        distribution[drinkType] = (distribution[drinkType] ?? 0) + amount;
      }
    }

    return distribution;
  }

  /// Delete a water log
  Future<void> deleteWaterLog(String logId) async {
    await _waterLogsRef().child(logId).remove();
  }

  // ==================== WEEKLY STATS ====================

  /// Get reference to weekly stats path
  DatabaseReference _weeklyStatsRef() {
    if (_userId == null) throw Exception('User not authenticated');
    return _database.ref('weekly_stats/$_userId/water_current_week');
  }

  /// Update weekly stats
  Future<void> updateWeeklyStats() async {
    final now = DateTime.now();
    final weekStart = now.weekStart;
    
    // Calculate total for current week
    int totalML = 0;
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      totalML += await getTotalIntakeForDate(date);
    }

    final stats = WeeklyWaterStats(
      weekStartDate: weekStart.toIso8601String(),
      totalAmountML: totalML,
      lastUpdate: now.toIso8601String(),
    );

    await _weeklyStatsRef().set(stats.toJson());
  }

  /// Get current week stats
  Stream<WeeklyWaterStats> getWeeklyStats() {
    return _weeklyStatsRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return WeeklyWaterStats(
          weekStartDate: DateTime.now().weekStart.toIso8601String(),
          totalAmountML: 0,
          lastUpdate: DateTime.now().toIso8601String(),
        );
      }

      return WeeklyWaterStats.fromJson(Map<String, dynamic>.from(data));
    });
  }

  /// Get weekly data for chart (7 days)
  Future<List<int>> getWeeklyData() async {
    final now = DateTime.now();
    final weekStart = now.weekStart;
    
    final List<int> weeklyData = [];
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final total = await getTotalIntakeForDate(date);
      weeklyData.add(total);
    }

    return weeklyData;
  }

  // ==================== HELPER METHODS ====================

  /// Calculate progress towards daily goal
  Future<double> getProgressForDate(DateTime date, int dailyGoal) async {
    final total = await getTotalIntakeForDate(date);
    return (total / dailyGoal).clamp(0.0, 1.0);
  }

  /// Check if daily goal is achieved
  Future<bool> isGoalAchieved(DateTime date, int dailyGoal) async {
    final total = await getTotalIntakeForDate(date);
    return total >= dailyGoal;
  }
}
