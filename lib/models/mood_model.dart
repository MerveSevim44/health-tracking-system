import 'package:flutter/material.dart';

class MoodModel extends ChangeNotifier {
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

  // !!! HATA GİDERİCİ DEĞİŞİKLİK BURADA !!!
  // Eğer _selectedMoodIndex null ise, -1 döndürülerek her zaman int tipi garantilenir.
  int get selectedMoodIndex => _selectedMoodIndex ?? -1;
  // !!! HATA GİDERİCİ DEĞİŞİKLİK SONU !!!

  // Gün hakkındaki notu tutar
  String _dailyNote = '';
  String get dailyNote => _dailyNote;

  // Ruh hali seçimini günceller
  void selectMood(int index) {
    _selectedMoodIndex = index;
    notifyListeners(); // Arayüzü yeniden çizmek için dinleyicilere haber verir
  }

  // Notu günceller
  void updateDailyNote(String note) {
    _dailyNote = note;
    notifyListeners();
  }
}