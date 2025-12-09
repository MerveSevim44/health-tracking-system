// 📁 lib/services/mood_service.dart
// Firebase service for mood tracking

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
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

  /// Add a new mood entry
  Future<String> addMood({
    required int moodLevel,
    required List<String> emotions,
    String notes = '',
    double sentimentScore = 0.0,
    double sentimentMagnitude = 0.0,
  }) async {
    final mood = MoodFirebase(
      id: '',
      date: DateTime.now().toIso8601String(),
      moodLevel: moodLevel,
      emotions: emotions,
      notes: notes,
      sentimentScore: sentimentScore,
      sentimentMagnitude: sentimentMagnitude,
    );

    final ref = _moodsRef().push();
    await ref.set(mood.toJson());
    return ref.key!;
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

  /// Get mood for today
  Future<MoodFirebase?> getTodayMood() async {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final snapshot = await _moodsRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return null;

    for (var entry in data.entries) {
      final mood = MoodFirebase.fromJson(
        entry.key as String,
        Map<String, dynamic>.from(entry.value as Map),
      );
      
      if (mood.date.startsWith(todayKey)) {
        return mood;
      }
    }

    return null;
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
}
