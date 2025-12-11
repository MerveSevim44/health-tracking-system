import 'package:flutter/material.dart';
import 'package:health_care/services/mood_service.dart';

class MoodModel extends ChangeNotifier {
  final MoodService _service = MoodService();
  // --- YENİ EKLENEN KISIM ---
  // Ruh halleri indeksleri ve etiketleri
  final Map<int, String> _moodLabels = const {
    0: 'Mutlu',
    1: 'Sakin',
    2: 'Üzgün',
    3: 'Kaygılı',
    4: 'Kızgın',
  };

  // Yeni Metot: İndekse göre ruh hali etiketini döndürür.
  String getMoodLabel(int index) {
    return _moodLabels[index] ?? 'Belirsiz';
  }
  // --- EKLENEN KISIM SONU ---

  // Seçilen ruh halini tutar (Index olarak, 0: Mutlu, 1: Sakin, vb.)
  int? _selectedMoodIndex;
  
  // Selected emotions (multiple selection support for Firebase)
  List<String> _selectedEmotions = [];

  // Eğer _selectedMoodIndex null ise, -1 döndürür
  int get selectedMoodIndex => _selectedMoodIndex ?? -1;
  
  List<String> get selectedEmotions => _selectedEmotions;

  // Gün hakkındaki notu tutar
  String _dailyNote = '';
  String get dailyNote => _dailyNote;

  // Ruh hali seçimini günceller
  void selectMood(int index) {
    _selectedMoodIndex = index;
    notifyListeners(); // Arayüzü yeniden çizmek için dinleyicilere haber verir
  }

  // Toggle emotion selection (for multiple emotions)
  void toggleEmotion(String emotion) {
    if (_selectedEmotions.contains(emotion)) {
      _selectedEmotions.remove(emotion);
    } else {
      _selectedEmotions.add(emotion);
    }
    notifyListeners();
  }

  // Set emotions list
  void setEmotions(List<String> emotions) {
    _selectedEmotions = emotions;
    notifyListeners();
  }

  // Notu günceller
  void updateDailyNote(String note) {
    _dailyNote = note;
    notifyListeners();
  }

  // Save mood to Firebase
  Future<void> saveMood() async {
    if (_selectedMoodIndex == null || _selectedMoodIndex! < 0) {
      throw Exception('Please select a mood level');
    }

    // Convert index to 1-5 scale for Firebase
    final moodLevel = _selectedMoodIndex! + 1;

    await _service.addMood(
      moodLevel: moodLevel,
      emotions: _selectedEmotions,
      notes: _dailyNote,
      sentimentScore: 0.0,
      sentimentMagnitude: 0.0,
    );

    notifyListeners();
  }

  // Load today's mood
  Future<void> loadTodayMood() async {
    final mood = await _service.getTodayMood();
    if (mood != null) {
      _selectedMoodIndex = mood.moodLevel - 1;
      _selectedEmotions = mood.emotions;
      _dailyNote = mood.notes;
      notifyListeners();
    }
  }

  // Get mood streak
  Future<int> getMoodStreak() async {
    return await _service.getMoodStreak();
  }

  // Get weekly mood data
  Future<List<int>> getWeeklyMoodData() async {
    return await _service.getWeeklyMoodData();
  }

  // Get last 7 mood entries for a user
  Future<List<MoodEntry>> getLast7Moods(String uid) async {
    final firebaseMoods = await _service.getLast7Moods(uid);
    
    // Convert MoodFirebase to MoodEntry (UI model)
    return firebaseMoods.map((fb) => MoodEntry(
      date: DateTime.parse(fb.date),
      moodLevel: fb.moodLevel,
      emotions: fb.emotions,
      sentimentScore: fb.sentimentScore,
      notes: fb.notes.isEmpty ? null : fb.notes,
    )).toList();
  }

  // Clear selection
  void clearSelection() {
    _selectedMoodIndex = null;
    _selectedEmotions = [];
    _dailyNote = '';
    notifyListeners();
  }
}

/// UI-friendly mood entry model
class MoodEntry {
  final DateTime date;
  final int moodLevel;
  final List<String> emotions;
  final double sentimentScore;
  final String? notes;

  MoodEntry({
    required this.date,
    required this.moodLevel,
    required this.emotions,
    this.sentimentScore = 0.0,
    this.notes,
  });
}