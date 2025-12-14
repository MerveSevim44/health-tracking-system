// 📁 lib/services/sleep_service.dart
// Firebase service for sleep tracking

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/sleep_model.dart';

class SleepService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  String? get _userId => _auth.currentUser?.uid;

  /// Get reference to sleep logs path: sleep_logs/{uid}/{YYYY-MM-DD}
  DatabaseReference _sleepLogsRef() {
    if (_userId == null) throw Exception('User not authenticated');
    return _database.ref('sleep_logs/$_userId');
  }

  /// Add or update sleep entry for today
  Future<String> addSleep({
    required DateTime bedTime,
    required DateTime wakeTime,
    int quality = 3,
  }) async {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final sleepLog = SleepLog.fromDateTimes(
      date: dateKey,
      bedTimeDate: bedTime,
      wakeTimeDate: wakeTime,
      quality: quality,
    );

    // Save to sleep_logs/{uid}/{dateKey}
    final ref = _sleepLogsRef().child(dateKey);
    await ref.set(sleepLog.toJson());
    return dateKey;
  }

  /// Get sleep entry for today
  Future<SleepLog?> getTodaySleep() async {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final snapshot = await _sleepLogsRef().child(todayKey).get();
    
    if (!snapshot.exists) return null;

    try {
      return SleepLog.fromJson(
        todayKey,
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      debugPrint('Error parsing today\'s sleep: $e');
      return null;
    }
  }

  /// Get sleep entries for a date range
  Future<List<SleepLog>> getSleepForDateRange(DateTime start, DateTime end) async {
    final snapshot = await _sleepLogsRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return [];

    final startKey = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endKey = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    return data.entries
        .where((entry) {
          final key = entry.key as String;
          return key.compareTo(startKey) >= 0 && key.compareTo(endKey) <= 0;
        })
        .map((entry) => SleepLog.fromJson(
              entry.key as String,
              Map<String, dynamic>.from(entry.value as Map),
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get last 7 days of sleep data
  Future<List<SleepLog>> getWeeklySleep() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getSleepForDateRange(weekAgo, now);
  }

  /// Get average sleep duration for a date range
  Future<double> getAverageSleepDuration(DateTime start, DateTime end) async {
    final sleepEntries = await getSleepForDateRange(start, end);
    
    if (sleepEntries.isEmpty) return 0.0;

    final sum = sleepEntries.fold<double>(0, (sum, sleep) => sum + sleep.durationHours);
    return sum / sleepEntries.length;
  }

  /// Update sleep entry
  Future<void> updateSleep(SleepLog sleepLog) async {
    await _sleepLogsRef().child(sleepLog.date).update(sleepLog.toJson());
  }

  /// Delete sleep entry
  Future<void> deleteSleep(String dateKey) async {
    await _sleepLogsRef().child(dateKey).remove();
  }

  /// Get sleep quality statistics
  Future<Map<String, dynamic>> getSleepStats() async {
    final weeklySleep = await getWeeklySleep();
    
    if (weeklySleep.isEmpty) {
      return {
        'avgDuration': 0.0,
        'avgQuality': 0.0,
        'totalNights': 0,
      };
    }

    final avgDuration = weeklySleep.fold<double>(0, (sum, s) => sum + s.durationHours) / weeklySleep.length;
    final avgQuality = weeklySleep.fold<int>(0, (sum, s) => sum + s.quality) / weeklySleep.length;

    return {
      'avgDuration': avgDuration,
      'avgQuality': avgQuality,
      'totalNights': weeklySleep.length,
    };
  }
}
