  // 📁 lib/services/firebase_gemini_service.dart
// DeepSeek AI integration using HTTP API
// 
// ✅ IMPLEMENTATION:
// - Uses DeepSeek API via HTTP POST request
// - Flow: Flutter → DeepSeek API
// - Production-ready with proper error handling

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseGeminiService {
  static const String _apiUrl = 'https://sii3.top/api/deepseek/api.php';
  static const String _apiKey = 'DarkAI-DeepAI-8E19926A026AFE61A4AC41FC';
  
  String _currentSystemInstruction = '';
  
  // Mood-specific system prompts (Turkish)
  final Map<int, String> _moodPrompts = {
    0: "Kullanıcı kendini **Mutlu** hissettiğini belirtti. Cevapların kutlayıcı, neşeli ve pozitif enerjiyi sürdüren bir tonda olmalıdır. Başarısını veya pozitifliğini tebrik et.",
    1: "Kullanıcı kendini **Sakin** hissettiğini belirtti. Cevapların huzurlu, dinlendirici ve meditasyonu veya şimdiki anı destekleyen bir tonda olmalıdır. Derin düşüncelere yönlendir.",
    2: "Kullanıcı kendini **Üzgün** hissettiğini belirtti. Cevapların son derece empatik, destekleyici ve yargılayıcı olmayan bir tonda olmalıdır. Onaylayıcı dil kullan (örneğin, 'Hislerinin tamamen doğal olduğunu anlıyorum.'). Çözüm sunmak yerine dinlemeye odaklan.",
    3: "Kullanıcı kendini **Kaygılı** hissettiğini belirtti. Cevapların güven verici, sakinleştirici ve somut başa çıkma stratejilerine (nefes egzersizi, topraklanma teknikleri) odaklanan bir tonda olmalıdır. Kısa ve net cümleler kur, uzun cevaplardan kaçın.",
    4: "Kullanıcı kendini **Kızgın** hissettiğini belirtti. Cevapların sabırlı, nötr ve duyguyu kabul eden bir tonda olmalıdır. Sakinleşmesine yardımcı olacak adımlar önerebilir veya sadece duygusunu boşaltmasına izin verebilirsin. Asla savunmacı veya itirazcı olma.",
  };

  /// Initialize the AI service with mood-based system instruction
  /// 
  /// Parameters:
  /// - [selectedMoodIndex]: User's current mood (0-4)
  /// - [customSystemInstruction]: Optional custom system instruction to override mood-based prompt
  void initialize({
    int selectedMoodIndex = 0,
    String? customSystemInstruction,
  }) {
    try {
      // Get mood-specific system prompt or use custom/default
      _currentSystemInstruction = customSystemInstruction ??
          _moodPrompts[selectedMoodIndex] ??
          "Sen bir destekleyici yapay zeka asistansın. Daima nazik, empatik ve yargılayıcı olmayan bir tonda cevap ver.";

      debugPrint('🔥 Initializing DeepSeek AI service');
      debugPrint('📝 System instruction: ${_currentSystemInstruction.substring(0, 50)}...');
      debugPrint('✅ DeepSeek AI Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing DeepSeek AI Service: $e');
      // Re-throw to let caller handle initialization errors
      rethrow;
    }
  }

  /// Send a message to DeepSeek AI and get response
  /// 
  /// Returns:
  /// - AI response text on success
  /// - Turkish fallback message on error: "Bugün kendine küçük bir iyilik yapmayı unutma 🌿"
  /// 
  /// Error handling:
  /// - No crashes
  /// - No repeated API retries
  /// - No error spam in logs
  Future<String> sendMessage(String userMessage) async {
    try {
      debugPrint('📤 Sending message to DeepSeek API: ${userMessage.length} chars');

      // Combine system instruction with user message for context
      final fullMessage = _currentSystemInstruction.isNotEmpty
          ? '$_currentSystemInstruction\n\nKullanıcı mesajı: $userMessage'
          : userMessage;

      // Make POST request to DeepSeek API
      final response = await http.post(
        Uri.parse(_apiUrl),
        body: {
          'key': _apiKey,
          'v3': fullMessage,
        },
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success' && jsonResponse['response'] != null) {
          final responseText = jsonResponse['response'] as String;
          debugPrint('✅ Received AI response: ${responseText.length} chars');
          return responseText.trim();
        } else {
          debugPrint('⚠️ API returned error status, using fallback');
          return _getFallbackMessage();
        }
      } else {
        debugPrint('⚠️ HTTP error ${response.statusCode}, using fallback');
        return _getFallbackMessage();
      }
    } catch (e) {
      // 🛡️ MANDATORY ERROR HANDLING
      // Silent logging - no technical errors exposed to user
      debugPrint('❌ DeepSeek API Error (using fallback): ${e.runtimeType}');
      
      // Return safe Turkish fallback message
      return _getFallbackMessage();
    }
  }

  /// Generate initial welcome message based on mood
  /// 
  /// Parameters:
  /// - [selectedMoodIndex]: User's current mood (0-4)
  /// - [moodLabel]: Human-readable mood label
  String generateInitialMessage({
    required int selectedMoodIndex,
    required String moodLabel,
  }) {
    // Generate mood-specific welcome message
    switch (selectedMoodIndex) {
      case 0: // Mutlu
        return "Harika! Enerjin bana da geçti! $moodLabel hissetmene sevindim. Bugün ne hakkında konuşmak istersin?";
      case 2: // Üzgün
        return "Merhaba. Bugün kendini $moodLabel hissediyormuşsun. Unutma, burası yargılanmadan her şeyi paylaşabileceğin güvenli bir alan. Seni dinlemek için buradayım, nasılsın?";
      case 3: // Kaygılı
        return "Merhaba, $moodLabel hissettiğini görüyorum. Bir nefes al. Şu an ne seni en çok meşgul ediyor? Eğer konuşmak zorsa, sadece 'Buradayım' yazabilirsin.";
      default:
        return "Merhaba! $moodLabel hissettiğini görüyorum. Seni dinliyorum. Bugün konuşmak istediğin konu ne?";
    }
  }

  /// Clear chat history and start fresh conversation
  void resetConversation({int selectedMoodIndex = 0}) {
    debugPrint('🔄 Resetting conversation with mood index: $selectedMoodIndex');
    initialize(selectedMoodIndex: selectedMoodIndex);
  }

  /// Get Turkish fallback message when AI fails
  /// As per requirements: "Bugün kendine küçük bir iyilik yapmayı unutma 🌿"
  String _getFallbackMessage() {
    return "Bugün kendine küçük bir iyilik yapmayı unutma 🌿";
  }
}

