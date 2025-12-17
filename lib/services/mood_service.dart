// 📁 lib/services/mood_service.dart
// Firebase service for mood tracking

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:health_care/models/mood_firebase_model.dart';

class MoodService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  String? get _userId => _auth.currentUser?.uid;

  // ==================== MOODS ====================

  /// Get reference to moods path
  DatabaseReference _moodsRef() {
    if (_userId == null) throw Exception('User not authenticated');
    return _database.ref('moods/$_userId');
  }

  /// Add a new mood entry with date-based structure: moods/{uid}/{YYYY-MM-DD}
  Future<String> addMood({
    required int moodLevel,
    required List<String> emotions,
    String notes = '',
    double sentimentScore = 0.0,
    double sentimentMagnitude = 0.0,
  }) async {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final mood = MoodFirebase(
      id: dateKey,
      date: now.toIso8601String(),
      moodLevel: moodLevel,
      emotions: emotions,
      notes: notes,
      sentimentScore: sentimentScore,
      sentimentMagnitude: sentimentMagnitude,
    );

    // Save with date as key to prevent duplicates for the same day
    final ref = _moodsRef().child(dateKey);
    await ref.set(mood.toJson());
    return dateKey;
  }

  /// Update existing mood
  Future<void> updateMood(MoodFirebase mood) async {
    await _moodsRef().child(mood.id).update(mood.toJson());
  }

  /// Delete mood entry
  Future<void> deleteMood(String moodId) async {
    await _moodsRef().child(moodId).remove();
  }

  /// Get all mood entries
  Stream<List<MoodFirebase>> getMoods() {
    return _moodsRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <MoodFirebase>[];

      return data.entries.map((entry) {
        return MoodFirebase.fromJson(
          entry.key as String,
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    });
  }

  /// Get mood for today using date-based structure
  Future<MoodFirebase?> getTodayMood() async {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final snapshot = await _moodsRef().child(todayKey).get();
    
    if (!snapshot.exists) return null;

    try {
      return MoodFirebase.fromJson(
        todayKey,
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } catch (e) {
      debugPrint('Error parsing today\'s mood: $e');
      return null;
    }
  }

  /// Get moods for a specific date range
  Future<List<MoodFirebase>> getMoodsForDateRange(DateTime start, DateTime end) async {
    final snapshot = await _moodsRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return [];

    final startDate = start.toIso8601String();
    final endDate = end.toIso8601String();

    return data.entries
        .map((entry) => MoodFirebase.fromJson(
              entry.key as String,
              Map<String, dynamic>.from(entry.value as Map),
            ))
        .where((mood) => 
            mood.date.compareTo(startDate) >= 0 && 
            mood.date.compareTo(endDate) <= 0)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get moods for the current week
  Future<List<MoodFirebase>> getWeeklyMoods() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    return getMoodsForDateRange(weekStart, weekEnd);
  }

  // ==================== STATISTICS ====================

  /// Get average mood level for a date range
  Future<double> getAverageMoodLevel(DateTime start, DateTime end) async {
    final moods = await getMoodsForDateRange(start, end);
    
    if (moods.isEmpty) return 0.0;

    final sum = moods.fold<int>(0, (sum, mood) => sum + mood.moodLevel);
    return sum / moods.length;
  }

  /// Get most common emotions for a date range
  Future<Map<String, int>> getEmotionFrequency(DateTime start, DateTime end) async {
    final moods = await getMoodsForDateRange(start, end);
    
    final Map<String, int> frequency = {};

    for (var mood in moods) {
      for (var emotion in mood.emotions) {
        frequency[emotion] = (frequency[emotion] ?? 0) + 1;
      }
    }

    return frequency;
  }

  /// Get mood streak (consecutive days with logged mood)
  Future<int> getMoodStreak() async {
    final snapshot = await _moodsRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return 0;

    final moods = data.entries
        .map((entry) => MoodFirebase.fromJson(
              entry.key as String,
              Map<String, dynamic>.from(entry.value as Map),
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? lastDate;

    for (var mood in moods) {
      final moodDate = DateTime.parse(mood.date);
      
      if (lastDate == null) {
        // First mood
        lastDate = moodDate;
        streak = 1;
      } else {
        final difference = lastDate.difference(moodDate).inDays;
        
        if (difference == 1) {
          // Consecutive day
          streak++;
          lastDate = moodDate;
        } else {
          // Streak broken
          break;
        }
      }
    }

    return streak;
  }

  /// Get weekly mood data for charts (7 values)
  Future<List<int>> getWeeklyMoodData() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final List<int> weeklyData = [];
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final snapshot = await _moodsRef().get();
      final data = snapshot.value as Map<dynamic, dynamic>?;
      
      int dayMood = 0;
      
      if (data != null) {
        for (var entry in data.values) {
          final mood = entry as Map;
          if ((mood['date'] as String).startsWith(dateKey)) {
            dayMood = mood['moodLevel'] as int? ?? 0;
            break;
          }
        }
      }
      
      weeklyData.add(dayMood);
    }

    return weeklyData;
  }

  /// Get last 7 mood entries for a specific user
  /// Returns the most recent 7 mood entries sorted by date (descending)
  /// Safe parsing: skips entries with missing required fields
  Future<List<MoodFirebase>> getLast7Moods(String uid) async {
    try {
      // Get reference to the specified user's moods
      final ref = _database.ref('moods/$uid');
      final snapshot = await ref.get();
      
      // Check if data exists
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      // Parse all mood entries with safe error handling
      final List<MoodFirebase> allMoods = [];
      
      for (var entry in data.entries) {
        try {
          final moodId = entry.key as String;
          final moodData = entry.value as Map<dynamic, dynamic>;
          
          // Skip if essential fields are missing
          if (!moodData.containsKey('date') || !moodData.containsKey('moodLevel')) {
            continue;
          }
          
          // Safe parsing with defaults
          final mood = MoodFirebase(
            id: moodId,
            date: moodData['date'] as String? ?? DateTime.now().toIso8601String(),
            moodLevel: moodData['moodLevel'] as int? ?? 3,
            emotions: (moodData['emotions'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ?? 
                [],
            notes: moodData['notes'] as String? ?? '',
            sentimentScore: (moodData['sentimentScore'] as num?)?.toDouble() ?? 0.0,
            sentimentMagnitude: (moodData['sentimentMagnitude'] as num?)?.toDouble() ?? 0.0,
          );
          
          allMoods.add(mood);
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
      
      // Sort by date descending (most recent first)
      allMoods.sort((a, b) => b.date.compareTo(a.date));
      
      // Take only the first 7 entries
      return allMoods.take(7).toList();
      
    } catch (e) {
      // Return empty list on any error
      return [];
    }
  }

  /// Get emotion distribution from last 7 days
  /// Data source: Firebase → moods/{uid}/{YYYY-MM-DD}/emotions[]
  /// Returns percentage for each emotion found in the last 7 days
  Future<Map<String, double>> getLast7DaysEmotionDistribution() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      // Get moods from last 7 days
      final moods = await getMoodsForDateRange(sevenDaysAgo, now);
      
      if (moods.isEmpty) return {};

      // Count each emotion
      final Map<String, int> emotionCounts = {};
      int totalEmotions = 0;

      for (var mood in moods) {
        for (var emotion in mood.emotions) {
          emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
          totalEmotions++;
        }
      }

      // If no emotions found
      if (totalEmotions == 0) return {};

      // Calculate percentages
      final Map<String, double> distribution = {};
      emotionCounts.forEach((emotion, count) {
        distribution[emotion] = (count / totalEmotions) * 100;
      });

      return distribution;
    } catch (e) {
      debugPrint('Error getting emotion distribution: $e');
      return {};
    }
  }
}
