// 📁 lib/services/ai_coach_service.dart
// DeepSeek AI integration service for personalized health coaching
//
// 🛡️ FALLBACK MECHANISM:
// - ALL API calls are wrapped in try-catch with fallback messages
// - If API fails (quota, network, timeout), returns friendly Turkish fallback message
// - Daily failure cache: if API fails once today, subsequent calls skip API and use fallback
// - Never shows error messages to users - always returns a warm, motivating message
// - Fallback messages are cached per day for consistency

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
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
  
  // 🔑 DeepSeek API Configuration
  static const String _apiUrl = 'https://sii3.top/api/deepseek/api.php';
  static const String _apiKey = 'DarkAI-DeepAI-8E19926A026AFE61A4AC41FC';
  
  // 🛡️ Fallback messages - Turkish motivational messages
  static const List<String> _fallbackMessages = [
    'Bugün kendine küçük bir iyilik yapmayı unutma 🌿',
    'Her gün yeni bir başlangıç, bugün de senin günün 💫',
    'Kendine karşı nazik ol, bugün de elinden geleni yaptın 🌱',
    'Küçük adımlar büyük değişimler getirir, devam et ✨',
    'Bugün de sağlıklı seçimler yapmak için harika bir gün 🌟',
    'Nefes al, rahatla, şu an tam olarak olman gereken yerde olabilirsin 💙',
    'Her gün biraz daha iyi olmak için bir fırsat, bugünü değerlendir 🌸',
    'Kendine iyi bakmak en önemli yatırım, bugün de kendine zaman ayır 💜',
  ];
  
  // Cache for daily fallback messages (prevents multiple API calls on same day if one fails)
  String? _cachedFallbackMessage;
  DateTime? _cachedFallbackDate;
  
  // Daily failure cache - if API failed today, use fallback immediately for subsequent calls
  bool _apiFailedToday = false;
  DateTime? _lastFailureDate;
  
  AiCoachService() {
    debugPrint('✅ AI Coach Service initialized with DeepSeek API');
  }
  
  /// Check if API failed today - if so, skip API call and use fallback immediately
  bool _shouldSkipApiCall() {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    
    // Reset failure flag if it's a new day
    if (_lastFailureDate != null) {
      final lastFailureKey = DateTime(
        _lastFailureDate!.year,
        _lastFailureDate!.month,
        _lastFailureDate!.day,
      );
      
      if (lastFailureKey.year != todayKey.year ||
          lastFailureKey.month != todayKey.month ||
          lastFailureKey.day != todayKey.day) {
        _apiFailedToday = false;
        _lastFailureDate = null;
      }
    }
    
    return _apiFailedToday;
  }
  
  /// Mark API as failed for today
  void _markApiFailed() {
    _apiFailedToday = true;
    _lastFailureDate = DateTime.now();
    debugPrint('🛡️ [AI Coach] API marked as failed for today - using fallback for subsequent calls');
  }
  
  /// Get a random fallback message (cached per day)
  String _getFallbackMessage() {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    
    // Return cached message if it's from today
    if (_cachedFallbackMessage != null && 
        _cachedFallbackDate != null &&
        _cachedFallbackDate!.year == todayKey.year &&
        _cachedFallbackDate!.month == todayKey.month &&
        _cachedFallbackDate!.day == todayKey.day) {
      return _cachedFallbackMessage!;
    }
    
    // Get new random fallback message
    final message = _fallbackMessages[_random.nextInt(_fallbackMessages.length)];
    _cachedFallbackMessage = message;
    _cachedFallbackDate = todayKey;
    
    return message;
  }
  
  /// Execute DeepSeek API call with comprehensive error handling and fallback
  Future<String> _executeDeepSeekCall(String prompt) async {
    // If API already failed today, skip call and return fallback immediately
    if (_shouldSkipApiCall()) {
      debugPrint('🛡️ [AI Coach] Skipping API call - already failed today, using cached fallback');
      return _getFallbackMessage();
    }
    
    try {
      // Make POST request to DeepSeek API with timeout
      final response = await http.post(
        Uri.parse(_apiUrl),
        body: {
          'key': _apiKey,
          'v3': prompt,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [AI Coach] API call timeout - using fallback');
          throw TimeoutException('API call timeout');
        },
      );
      
      if (response.statusCode == 200) {
        // Parse JSON response
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success' && jsonResponse['response'] != null) {
          final responseText = jsonResponse['response'] as String;
          
          // If we got here, API call succeeded - reset failure flag
          _apiFailedToday = false;
          return responseText.trim();
        }
      }
      
      // API returned error - mark as failed
      _markApiFailed();
      return _getFallbackMessage();
    } on TimeoutException {
      // Timeout - mark as failed and return fallback
      _markApiFailed();
      return _getFallbackMessage();
    } catch (e) {
      // 🛡️ Silent error logging - no technical details exposed to user
      debugPrint('❌ [AI Coach] DeepSeek API Error (silent fallback): ${e.runtimeType}');
      
      // Mark API as failed for today
      _markApiFailed();
      
      // Return friendly fallback message instead of error
      return _getFallbackMessage();
    }
  }

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
      debugPrint('❌ Error getting AI Coach settings: $e');
      return const AiCoachSettings();
    }
  }

  /// Update AI Coach settings
  Future<void> updateSettings(AiCoachSettings settings) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _dbRef.child('users/$_userId/aiCoach').set(settings.toJson());
      debugPrint('✅ AI Coach settings updated');
    } catch (e) {
      debugPrint('❌ Error updating AI Coach settings: $e');
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

  /// Generate response to mood submission using DeepSeek AI
  Future<String> generateMoodResponse({
    required int moodLevel,
    required List<String> emotions,
  }) async {
    try {
      final moodLabels = {
        5: 'harika',
        4: 'iyi',
        3: 'normal',
        2: 'kötü',
        1: 'çok kötü'
      };
      
      final emotionsText = emotions.isEmpty 
          ? 'belirtilmedi' 
          : emotions.map((e) => _emotionTranslations[e] ?? e).join(', ');
      
      final prompt = '''
Sen empatik ve destekleyici bir sağlık koçusun. Adın "AI Health Coach". Kullanıcı bugün kendini şöyle hissediyor:

- Ruh hali seviyesi: $moodLevel/5 (${moodLabels[moodLevel]})
- Hissettiği duygular: $emotionsText

Görevin:
1. Kullanıcının duygularını anlayıp empati kur
2. Duygularını onaylayan samimi bir yanıt ver
3. Küçük, uygulanabilir bir tavsiye sun (nefes egzersizi, kısa yürüyüş, su içme vb.)
4. Pozitif ve cesaretlendirici ol
5. Türkçe yanıtla
6. Maksimum 100 kelime
7. Emoji kullan (ama abartma, 1-2 tane yeterli)

Dikkat: Çok genel veya yapay cevaplar verme. Kullanıcının seçtiği duyguları mutlaka yanıtına dahil et.
''';

      return await _executeDeepSeekCall(prompt);
    } catch (e) {
      // Additional safety net - return contextual fallback
      return _getFallbackMoodResponse(moodLevel, emotions);
    }
  }
  
  /// Emotion translations for Turkish prompts
  final Map<String, String> _emotionTranslations = {
    'happy': 'mutlu',
    'sad': 'üzgün',
    'angry': 'sinirli',
    'calm': 'sakin',
    'anxious': 'kaygılı',
    'tired': 'yorgun',
    'energetic': 'enerjik',
    'excited': 'heyecanlı',
  };
  
  /// Fallback response when AI fails - contextual based on mood
  String _getFallbackMoodResponse(int moodLevel, List<String> emotions) {
    // Use contextual fallback if mood is provided, otherwise use general fallback
    if (moodLevel >= 4) {
      return 'Harika hissediyorsun! Bu pozitif enerjini korumaya devam et 🌟';
    } else if (moodLevel == 3) {
      return 'Bugün normal bir gün. Kendine iyi bak 💙';
    } else if (moodLevel <= 2) {
      return 'Bugün biraz zorlanıyorsun gibi. Benimle konuşmak istersen buradayım 💜';
    }
    
    // General fallback if mood level is unknown
    return _getFallbackMessage();
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
  
  /// Generate chat response using DeepSeek AI
  Future<String> generateChatResponse(String userMessage) async {
    try {
      final prompt = '''
Sen empatik bir sağlık koçu asistanısın. Adın "AI Health Coach". 

Kullanıcının mesajı: "$userMessage"

Görevin:
1. Kullanıcının sorusuna veya mesajına uygun, yardımcı bir yanıt ver
2. Eğer sağlık, ruh hali, su, egzersiz, ilaç ile ilgiliyse profesyonel tavsiye ver
3. Samimi ve destekleyici ol
4. Kısa ve net cevap ver (maksimum 120 kelime)
5. Türkçe yanıtla
6. 1-2 emoji kullan

Önemli: Tıbbi teşhis koyma, sadece genel sağlık tavsiyeleri ver.
''';

      return await _executeDeepSeekCall(prompt);
    } catch (e) {
      // Additional safety net
      return _getFallbackMessage();
    }
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
