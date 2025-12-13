// 📁 lib/services/ai_coach_service.dart
// Rule-based AI message generation service

import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_models.dart';
import '../models/mood_firebase_model.dart';
import '../models/medication_firebase_model.dart';

class AiCoachService {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference get _dbRef => _database.ref();
  String? get _userId => _auth.currentUser?.uid;

  final Random _random = Random();

  /// Get AI Coach settings for user
  Future<AiCoachSettings> getSettings() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _dbRef.child('users/$_userId/aiCoach').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return AiCoachSettings.fromJson(data);
      }
      // Return default settings
      return const AiCoachSettings();
    } catch (e) {
      print('❌ Error getting AI Coach settings: $e');
      return const AiCoachSettings();
    }
  }

  /// Update AI Coach settings
  Future<void> updateSettings(AiCoachSettings settings) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _dbRef.child('users/$_userId/aiCoach').set(settings.toJson());
      print('✅ AI Coach settings updated');
    } catch (e) {
      print('❌ Error updating AI Coach settings: $e');
      rethrow;
    }
  }

  /// Generate AI message based on context
  Future<String> generateMessage({
    MoodFirebase? recentMood,
    int? waterIntake,
    List<MedicationFirebase>? missedMedications,
    String? timeOfDay,
  }) async {
    final settings = await getSettings();
    if (!settings.enabled) {
      return _getDefaultMessage();
    }

    // Determine time of day if not provided
    timeOfDay ??= _getTimeOfDay();

    // Generate contextual message
    return _buildContextualMessage(
      mood: recentMood,
      waterIntake: waterIntake,
      missedMeds: missedMedications,
      timeOfDay: timeOfDay,
      tone: settings.tone,
    );
  }

  /// Generate welcome message for daily check-in
  String generateCheckInWelcome() {
    final greetings = [
      'Merhaba! Bugün nasıl hissediyorsun? 🌸',
      'Günaydın! Bugünkü ruh halini paylaşmak ister misin? ☀️',
      'Hey! Bugün kendini nasıl hissediyorsun? 🌿',
      'Selam! Bugünkü enerjini merak ediyorum 💫',
      'Merhaba! Bugün nasıl başladı senin için? 🌱',
    ];
    return greetings[_random.nextInt(greetings.length)];
  }

  /// Generate response to mood submission
  String generateMoodResponse({
    required int moodLevel,
    required List<String> emotions,
  }) {
    if (moodLevel >= 4) {
      // Happy/Great mood
      final responses = [
        'Harika! Bugün pozitif enerjinle güzel şeyler yaratacaksın! ✨',
        'Muhteşem! Bu güzel enerjiyi korumaya devam et 🌟',
        'Ne güzel! Bugün senin günün gibi görünüyor 🎉',
        'Harika hissediyorsun! Bu enerjini korumak için su içmeyi unutma 💧',
      ];
      return responses[_random.nextInt(responses.length)];
    } else if (moodLevel == 3) {
      // Neutral mood
      final responses = [
        'Anladım, bugün normal bir gün. Küçük bir yürüyüş seni iyi hissettirebilir 🚶‍♀️',
        'Normal bir gün. Kendine iyi bak, su içmeyi unutma 💙',
        'Bugün standart bir mod. İstersen kısa bir meditasyon deneyelim? 🧘‍♀️',
        'Bugün böyle günlerden. Bir müzik dinlemek ister misin? 🎵',
      ];
      return responses[_random.nextInt(responses.length)];
    } else {
      // Low/Bad mood
      if (emotions.contains('anxious') || emotions.contains('stressed')) {
        final responses = [
          'Biraz gergin görünüyorsun. Derin nefes almayı dene: 4 san içe, 4 san tut, 4 san dışarı 🌿',
          'Stresli hissediyorsun. Biraz su iç ve 5 dakika göz dinlendirmesi yap 💚',
          'Kaygılı hissediyorsun. Küçük bir mola seni rahatlatabilir ☕',
        ];
        return responses[_random.nextInt(responses.length)];
      } else if (emotions.contains('sad')) {
        final responses = [
          'Üzgün görünüyorsun. Benimle konuşmak istersen buradayım 💙',
          'Bugün zor bir gün gibi. Kendine nazik ol, yavaşça ilerle 🌸',
          'Üzgün hissediyorsun. Sevdiğin bir şey yapmak seni rahatlatabilir 🎨',
        ];
        return responses[_random.nextInt(responses.length)];
      } else {
        final responses = [
          'Bugün biraz zorlanıyorsun gibi. Kendine iyi bak 💜',
          'Zor bir gün. Küçük adımlarla ilerle, acelesi yok 🌱',
          'Bugün biraz ağır hissediyorsun. Su içmeyi ve dinlenmeyi unutma 💧',
        ];
        return responses[_random.nextInt(responses.length)];
      }
    }
  }

  /// Generate daily tip message
  String generateDailyTip() {
    final tips = [
      '💧 Günde en az 8 bardak su içmeyi hedefle',
      '🧘‍♀️ Her gün 5 dakika meditasyon ruh halini iyileştirir',
      '🚶‍♀️ Kısa yürüyüşler endorfin salgılatır ve mood\'u yükseltir',
      '😴 Düzenli uyku rutini mental sağlık için çok önemli',
      '📱 Ekran molası ver, gözlerini dinlendir',
      '🌿 Derin nefes almak anında sakinleştirir',
      '📝 Duygularını yazmak stres azaltır',
      '🎵 Müzik dinlemek mood düzenleyici etkisi yapar',
      '☕ Kafein tüketimini dengele, fazlası kaygıyı artırabilir',
      '🌱 Küçük başarıları kutlamak motivasyon sağlar',
    ];
    return tips[_random.nextInt(tips.length)];
  }

  // ==================== PRIVATE HELPERS ====================

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }

  String _getDefaultMessage() {
    return 'Merhaba! Bugün sana nasıl yardımcı olabilirim? 😊';
  }

  String _buildContextualMessage({
    MoodFirebase? mood,
    int? waterIntake,
    List<MedicationFirebase>? missedMeds,
    required String timeOfDay,
    required String tone,
  }) {
    final messages = <String>[];

    // Check mood
    if (mood != null) {
      if (mood.moodLevel <= 2) {
        if (tone == 'gentle') {
          messages.add('Bugün biraz zorlanıyorsun gibi. Sana destek olmak isterim 💙');
        } else if (tone == 'energetic') {
          messages.add('Hey! Bugün zor görünüyor ama sen çok güçlüsün! 💪');
        } else {
          messages.add('Bugün ruh haliniz düşük görünüyor. Dinlenmenizi öneririm.');
        }
      }
    }

    // Check water intake
    if (waterIntake != null && waterIntake < 1500) {
      messages.add('Su tüketiminiz düşük. Hedef: ${(2000 - waterIntake).round()}ml daha 💧');
    }

    // Check missed medications
    if (missedMeds != null && missedMeds.isNotEmpty) {
      final count = missedMeds.length;
      messages.add('$count adet ilaç kaydı eksik. Almayı unutma! 💊');
    }

    // Time-based messages
    if (timeOfDay == 'morning' && messages.isEmpty) {
      messages.add('Günaydın! Güzel bir günün başlangıcı ☀️');
    } else if (timeOfDay == 'evening' && messages.isEmpty) {
      messages.add('İyi akşamlar! Bugünü tamamlamak üzeresin 🌙');
    }

    // Return combined or default message
    if (messages.isEmpty) {
      return generateDailyTip();
    }

    return messages.join('\n\n');
  }
}
