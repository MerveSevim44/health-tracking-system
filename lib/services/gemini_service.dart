// 📁 lib/services/gemini_service.dart
// Gemini AI integration for health coaching

import 'dart:async';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/mood_firebase_model.dart';
import '../models/medication_firebase_model.dart';

class GeminiService {
  // 🔑 API Key loaded from .env file
  // Add your key to .env: GEMINI_API_KEY=your_key_here
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  late final GenerativeModel _model;
  final List<Content> _conversationHistory = [];
  final Random _random = Random();
  
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
  
  // Cache for daily fallback messages
  String? _cachedFallbackMessage;
  DateTime? _cachedFallbackDate;
  
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

  GeminiService() {
    // ✅ CORRECT: Using gemini-2.5-flash (gemini-pro is deprecated)
    // Endpoint: https://generativelanguage.googleapis.com/v1beta/
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey.isEmpty ? 'AIzaSyBnpsgc7zFxt9Svi4vpVtnS7u0w7bgquew' : _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(
          HarmCategory.harassment,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.hateSpeech,
          HarmBlockThreshold.medium,
        ),
      ],
    );
  }

  /// Initialize conversation with system context
  void initializeContext({
    String? username,
    MoodFirebase? recentMood,
    int? waterIntake,
    List<MedicationFirebase>? medications,
  }) {
    final contextParts = <String>[
      'You are MINOA, a friendly and empathetic AI health coach.',
      'Your role is to support users in their health journey by providing:',
      '- Emotional support and mood tracking insights',
      '- Hydration reminders and tips',
      '- Medication adherence encouragement',
      '- General wellness advice',
      '',
      'Guidelines:',
      '- Be warm, supportive, and empathetic',
      '- Keep responses concise (2-3 sentences)',
      '- Use encouraging language',
      '- Suggest actionable health tips',
      '- Never provide medical diagnosis or replace professional healthcare',
      '',
    ];

    if (username != null) {
      contextParts.add('User name: $username');
    }

    if (recentMood != null) {
      contextParts.add('Recent mood: Level ${recentMood.moodLevel}/5');
      if (recentMood.emotions.isNotEmpty) {
        contextParts.add('Emotions: ${recentMood.emotions.join(", ")}');
      }
    }

    if (waterIntake != null) {
      contextParts.add('Today\'s water intake: ${waterIntake}ml');
    }

    if (medications != null && medications.isNotEmpty) {
      contextParts.add('Active medications: ${medications.length}');
    }

    final systemContext = contextParts.join('\n');
    
    _conversationHistory.clear();
    _conversationHistory.add(Content.text(systemContext));
  }

  /// Send a message and get AI response with retry logic
  Future<String> sendMessage(String userMessage) async {
    try {
      return await _executeWithRetry(() async {
        // Add user message to history
        _conversationHistory.add(Content.text(userMessage));

        // Start chat with history
        final chat = _model.startChat(history: _conversationHistory);
        
        // Get response
        final response = await chat.sendMessage(Content.text(userMessage));
        final aiResponse = response.text?.trim();
        
        if (aiResponse != null && aiResponse.isNotEmpty) {
          // Add AI response to history
          _conversationHistory.add(Content.model([TextPart(aiResponse)]));
          return aiResponse;
        }
        
        // Empty response fallback
        return _getFallbackMessage();
      });
    } catch (e) {
      // 🛡️ Silent error logging - no technical details exposed to user
      debugPrint('❌ [Gemini Service] API Error (silent fallback): ${e.runtimeType}');
      
      // Return friendly fallback message instead of error
      return _getFallbackMessage();
    }
  }

  /// Execute API call with fallback mechanism
  /// 🛡️ Returns fallback message instead of error messages (no retries)
  Future<String> _executeWithRetry(Future<String> Function() apiCall) async {
    // Do NOT retry immediately - return fallback on first error
    // This prevents quota exhaustion and provides instant user feedback
    try {
      return await apiCall();
    } catch (e) {
      final errorString = e.toString();
      
      // 🛡️ Silent error logging - no technical details exposed to user
      debugPrint('❌ [Gemini Service] API Error (silent fallback): ${e.runtimeType}');
      
      // Check for API key error (only case where we show a different message)
      if (errorString.contains('API_KEY') || errorString.contains('API key')) {
        return _getFallbackMessage(); // Still use fallback, don't expose technical details
      }
      
      // For ALL other errors (quota, network, timeout, etc.), return fallback
      // Do NOT retry, do NOT show error messages
      return _getFallbackMessage();
    }
  }

  /// Generate welcome message
  Future<String> generateWelcome({String? username}) async {
    final name = username ?? 'there';
    final prompt = 'Generate a warm, friendly greeting for $name as their health coach. Keep it short (1-2 sentences) and welcoming.';
    
    try {
      return await _executeWithRetry(() async {
        final response = await _model.generateContent([Content.text(prompt)]);
        final aiResponse = response.text?.trim();
        return aiResponse ?? _getFallbackMessage();
      });
    } catch (e) {
      // 🛡️ Silent error logging
      debugPrint('❌ [Gemini Service] Welcome message error (silent fallback): ${e.runtimeType}');
      return _getFallbackMessage();
    }
  }

  /// Generate mood-based response
  Future<String> generateMoodResponse({
    required int moodLevel,
    required List<String> emotions,
  }) async {
    final emotionsList = emotions.join(', ');
    final prompt = '''
    The user just logged their mood:
    - Mood level: $moodLevel/5 (1=awful, 5=great)
    - Emotions: $emotionsList
    
    As their health coach, provide a supportive 2-3 sentence response that:
    - Acknowledges their feelings
    - Offers a helpful tip or suggestion
    - Encourages them
    ''';
    
    try {
      return await _executeWithRetry(() async {
        final response = await _model.generateContent([Content.text(prompt)]);
        final aiResponse = response.text?.trim();
        return aiResponse ?? _getFallbackMoodResponse(moodLevel);
      });
    } catch (e) {
      // 🛡️ Silent error logging
      debugPrint('❌ [Gemini Service] Mood response error (silent fallback): ${e.runtimeType}');
      return _getFallbackMoodResponse(moodLevel);
    }
  }

  /// Generate daily health tip
  Future<String> generateDailyTip() async {
    final prompt = 'Give a short, actionable health tip about hydration, mood, or wellness. Keep it to 1 sentence with an emoji.';
    
    try {
      return await _executeWithRetry(() async {
        final response = await _model.generateContent([Content.text(prompt)]);
        final aiResponse = response.text?.trim();
        return aiResponse ?? _getFallbackMessage();
      });
    } catch (e) {
      // 🛡️ Silent error logging
      debugPrint('❌ [Gemini Service] Daily tip error (silent fallback): ${e.runtimeType}');
      return _getFallbackMessage();
    }
  }

  /// Get personalized health insights
  Future<String> generateHealthInsight({
    MoodFirebase? recentMood,
    int? waterIntake,
    int? waterGoal,
    List<MedicationFirebase>? medications,
  }) async {
    final contextParts = <String>[];
    
    if (recentMood != null) {
      contextParts.add('Recent mood: ${recentMood.moodLevel}/5');
    }
    if (waterIntake != null && waterGoal != null) {
      final percentage = (waterIntake / waterGoal * 100).round();
      contextParts.add('Water intake: $percentage% of goal ($waterIntake/$waterGoal ml)');
    }
    if (medications != null) {
      contextParts.add('${medications.length} active medications');
    }

    final prompt = '''
    Based on this health data:
    ${contextParts.join('\n')}
    
    Provide a brief, encouraging health insight or suggestion (2 sentences max).
    ''';
    
    try {
      return await _executeWithRetry(() async {
        final response = await _model.generateContent([Content.text(prompt)]);
        final aiResponse = response.text?.trim();
        return aiResponse ?? _getFallbackMessage();
      });
    } catch (e) {
      // 🛡️ Silent error logging
      debugPrint('❌ [Gemini Service] Health insight error (silent fallback): ${e.runtimeType}');
      return _getFallbackMessage();
    }
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }

  // Fallback responses when API fails - contextual based on mood
  String _getFallbackMoodResponse(int moodLevel) {
    if (moodLevel >= 4) {
      return 'Harika hissediyorsun! Bu pozitif enerjini korumaya devam et 🌟';
    } else if (moodLevel == 3) {
      return 'Bugün normal bir gün. Kendine iyi bak 💙';
    } else {
      return 'Bugün biraz zorlanıyorsun gibi. Benimle konuşmak istersen buradayım 💜';
    }
  }
}

