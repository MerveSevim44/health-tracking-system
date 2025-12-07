// models/mood_model.dart

import 'package:flutter/material.dart';

class MoodModel extends ChangeNotifier {
  int? _selectedMoodIndex;

  // !!! GÜNCELLEME BURADA !!!
  // getter artık her zaman int döndürüyor. Eğer _selectedMoodIndex null ise -1 döndürülür.
  int get selectedMoodIndex => _selectedMoodIndex ?? -1;

  void selectMood(int index) {
    if (_selectedMoodIndex != index) {
      _selectedMoodIndex = index;
      notifyListeners();
    }
  }

  // MoodSelector'daki etiketleri döndürmek için metot (MainContent tarafından kullanılır)
  String? getMoodLabel(int index) {
    // MoodSelector'daki sırayla eşleşmeli
    const List<String> moods = ['Mutlu', 'Sakin', 'Üzgün', 'Kaygılı', 'Kızgın'];
    return index >= 0 && index < moods.length ? moods[index] : null;
  }
}