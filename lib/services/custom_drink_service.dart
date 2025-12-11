// 📁 lib/services/custom_drink_service.dart
// Custom drinks için Firebase servisi

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_care/models/custom_drink_model.dart';

class CustomDrinkService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  String? get _userId => _auth.currentUser?.uid;

  // ==================== CUSTOM DRINKS ====================

  /// Get reference to custom drinks path
  DatabaseReference _customDrinksRef() {
    if (_userId == null) throw Exception('User not authenticated');
    return _database.ref('custom_drinks/$_userId');
  }

  /// Get reference to drink logs path
  DatabaseReference _drinkLogsRef() {
    if (_userId == null) throw Exception('User not authenticated');
    return _database.ref('drink_logs/$_userId');
  }

  /// Add a custom drink
  Future<String> addCustomDrink(CustomDrink drink) async {
    final ref = _customDrinksRef().push();
    final drinkWithId = drink.copyWith(
      id: ref.key!,
      createdAt: DateTime.now(),
    );
    
    await ref.set(drinkWithId.toJson());
    return ref.key!;
  }

  /// Get all custom drinks for user
  Stream<List<CustomDrink>> getCustomDrinks() {
    return _customDrinksRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <CustomDrink>[];

      return data.entries.map((entry) {
        return CustomDrink.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();
    });
  }

  /// Update a custom drink
  Future<void> updateCustomDrink(String drinkId, CustomDrink drink) async {
    await _customDrinksRef().child(drinkId).update(drink.toJson());
  }

  /// Delete a custom drink
  Future<void> deleteCustomDrink(String drinkId) async {
    await _customDrinksRef().child(drinkId).remove();
  }

  // ==================== DRINK LOGS ====================

  /// Add a drink log entry
  Future<String> addDrinkLog(DrinkLog log) async {
    final ref = _drinkLogsRef().push();
    await ref.set(log.toJson());
    return ref.key!;
  }

  /// Get all drink logs
  Stream<List<DrinkLog>> getDrinkLogs() {
    return _drinkLogsRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <DrinkLog>[];

      return data.entries.map((entry) {
        return DrinkLog.fromJson(
          entry.key as String,
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();
    });
  }

  /// Get drink logs for today
  Stream<List<DrinkLog>> getTodayDrinkLogs() {
    return getDrinkLogs().map((logs) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      return logs.where((log) {
        final logDate = DateTime(
          log.timestamp.year,
          log.timestamp.month,
          log.timestamp.day,
        );
        return logDate == today;
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Yeniden eskiye
    });
  }

  /// Get drink logs for a specific date
  Stream<List<DrinkLog>> getDrinkLogsForDate(DateTime date) {
    return getDrinkLogs().map((logs) {
      final targetDate = DateTime(date.year, date.month, date.day);
      
      return logs.where((log) {
        final logDate = DateTime(
          log.timestamp.year,
          log.timestamp.month,
          log.timestamp.day,
        );
        return logDate == targetDate;
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  /// Get total cups for today (excluding water)
  Future<int> getTodayTotalCups() async {
    final snapshot = await _drinkLogsRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int totalCups = 0;

    for (var entry in data.values) {
      final log = entry as Map;
      try {
        final timestamp = DateTime.parse(log['timestamp'] as String);
        final logDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
        
        if (logDate == today) {
          final drinkName = (log['drinkName'] as String? ?? '').toLowerCase();
          if (drinkName != 'water') {
            totalCups += (log['cups'] as int? ?? 1);
          }
        }
      } catch (e) {
        continue;
      }
    }

    return totalCups;
  }

  /// Delete a drink log
  Future<void> deleteDrinkLog(String logId) async {
    await _drinkLogsRef().child(logId).remove();
  }
}
