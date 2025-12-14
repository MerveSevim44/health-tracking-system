// 📁 lib/services/water_service.dart
// Firebase service for water tracking and drink logging

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:health_care/models/water_firebase_model.dart';
import 'package:health_care/models/drink_log_model.dart';
import 'package:health_care/services/notification_service.dart';

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
    String? drinkType, // "water" | "coffee" | "tea" | "matcha" (defaults to "water" if null)
    required int amountML,
  }) async {
    final now = DateTime.now();
    final log = WaterLogFirebase(
      id: '',
      drinkType: drinkType ?? 'water', // Default to 'water' if drinkType is null
      amountML: amountML,
      createdAt: now.toIso8601String(),
      date: now.toDateKey(),
    );

    final ref = _waterLogsRef().push();
    await ref.set(log.toJson());
    
    // 🔔 Reschedule water reminders after logging water
    try {
      await NotificationService().scheduleWaterReminders();
      debugPrint('✅ [WaterService] Water reminders rescheduled after logging');
    } catch (e) {
      debugPrint('⚠️ [WaterService] Failed to reschedule water reminders: $e');
    }
    
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

  // ==================== NEW ADVANCED FEATURES ====================

  /// Get daily logs with full details (for advanced UI)
  Future<List<WaterLogFirebase>> getDailyLogs(String uid, DateTime date) async {
    try {
      final ref = _database.ref('water_logs/$uid');
      final dateKey = date.toDateKey();
      final snapshot = await ref.get();
      
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      final List<WaterLogFirebase> logs = [];
      
      for (var entry in data.entries) {
        try {
          final logData = Map<String, dynamic>.from(entry.value as Map);
          
          // Filter by date
          if (logData['date'] == dateKey) {
            final log = WaterLogFirebase.fromJson(
              entry.key as String,
              logData,
            );
            logs.add(log);
          }
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
      
      // Sort by creation time (most recent first)
      logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return logs;
    } catch (e) {
      return [];
    }
  }

  /// Get total amount for a specific day (for specific user)
  Future<int> getDailyTotal(String uid, DateTime date) async {
    try {
      final logs = await getDailyLogs(uid, date);
      return logs.fold<int>(0, (sum, log) => sum + log.amountML);
    } catch (e) {
      return 0;
    }
  }

  /// Get drink type breakdown for a specific day
  /// Returns map like: { "water": 850, "coffee": 120, "tea": 300 }
  Future<Map<String, int>> getDrinkBreakdown(String uid, DateTime date) async {
    try {
      final logs = await getDailyLogs(uid, date);
      final Map<String, int> breakdown = {};
      
      for (var log in logs) {
        final drinkType = log.drinkType.toLowerCase();
        breakdown[drinkType] = (breakdown[drinkType] ?? 0) + log.amountML;
      }
      
      return breakdown;
    } catch (e) {
      return {};
    }
  }

  /// Add water log with custom log ID generation
  /// Format: log_YYYYMMDD_HHMM
  Future<String> addWaterLogWithCustomId({
    required String uid,
    String? drinkType,
    required int amountML,
  }) async {
    try {
      final now = DateTime.now();
      final customId = 'log_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      
      final log = WaterLogFirebase(
        id: customId,
        drinkType: drinkType ?? 'water',
        amountML: amountML,
        createdAt: now.toIso8601String(),
        date: now.toDateKey(),
      );

      final ref = _database.ref('water_logs/$uid/$customId');
      await ref.set(log.toJson());
      
      return customId;
    } catch (e) {
      throw Exception('Failed to add water log: $e');
    }
  }

  /// Update weekly stats for a specific user
  Future<void> updateWeeklyStatsForUser(String uid) async {
    try {
      final now = DateTime.now();
      final weekStart = now.weekStart;
      
      int totalML = 0;
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        totalML += await getDailyTotal(uid, date);
      }

      final stats = WeeklyWaterStats(
        weekStartDate: weekStart.toIso8601String(),
        totalAmountML: totalML,
        lastUpdate: now.toIso8601String(),
      );

      await _database
          .ref('weekly_stats/$uid/water_current_week')
          .set(stats.toJson());
    } catch (e) {
      // Fail silently or log error
    }
  }

  // ==================== DRINK LOGS (Non-Water) ====================

  /// Get reference to drink logs path
  DatabaseReference _drinkLogsRef() {
    if (_userId == null) throw Exception('User not authenticated');
    return _database.ref('drink_logs/$_userId');
  }

  /// Add a drink log entry (for non-water beverages)
  /// Always adds 200ml (1 cup) by default
  Future<String> addDrinkLog({
    required String drinkType, // "tea", "coffee", "green tea", etc.
    int amount = 200, // Default: 1 cup = 200ml
    int count = 1, // Default: 1 cup
  }) async {
    final now = DateTime.now();
    final log = DrinkLogFirebase(
      id: '',
      type: drinkType.toLowerCase(),
      amount: amount,
      unit: 'ml',
      count: count,
      timestamp: now.toIso8601String(),
    );

    final ref = _drinkLogsRef().push();
    await ref.set(log.toJson());
    return ref.key!;
  }

  /// Get all drink logs
  Stream<List<DrinkLogFirebase>> getDrinkLogs() {
    return _drinkLogsRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <DrinkLogFirebase>[];

      return data.entries.map((entry) {
        return DrinkLogFirebase.fromJson(
          entry.key as String,
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();
    });
  }

  /// Get drink logs for a specific date
  Stream<List<DrinkLogFirebase>> getDrinkLogsForDate(DateTime date) {
    final dateKey = date.toDateKey();
    return getDrinkLogs().map((logs) {
      return logs.where((log) {
        try {
          final logDate = DateTime.parse(log.timestamp);
          return logDate.toDateKey() == dateKey;
        } catch (e) {
          return false;
        }
      }).toList();
    });
  }

  /// Get drink count for a specific date (excluding water)
  Future<int> getDrinkCountForDate(DateTime date) async {
    final dateKey = date.toDateKey();
    final snapshot = await _drinkLogsRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return 0;

    int count = 0;
    for (var entry in data.values) {
      final log = entry as Map;
      try {
        final logDate = DateTime.parse(log['timestamp'] as String);
        if (logDate.toDateKey() == dateKey) {
          count += (log['count'] as int?) ?? 1;
        }
      } catch (e) {
        continue;
      }
    }

    return count;
  }

  /// Check if drink type is water
  bool isWater(String drinkType) {
    return drinkType.toLowerCase() == 'water';
  }
}
