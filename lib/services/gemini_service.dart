// 📁 lib/services/gemini_service.dart
// Gemini AI integration for health coaching

import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/mood_firebase_model.dart';
import '../models/medication_firebase_model.dart';

class GeminiService {
  // 🔑 API Key loaded from .env file
  // Add your key to .env: GEMINI_API_KEY=your_key_here
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  late final GenerativeModel _model;
  final List<Content> _conversationHistory = [];

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
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
    return _executeWithRetry(() async {
      // Add user message to history
      _conversationHistory.add(Content.text(userMessage));

      // Start chat with history
      final chat = _model.startChat(history: _conversationHistory);
      
      // Get response
      final response = await chat.sendMessage(Content.text(userMessage));
      final aiResponse = response.text ?? 'I\'m here to help! Could you tell me more?';

      // Add AI response to history
      _conversationHistory.add(Content.model([TextPart(aiResponse)]));

      return aiResponse;
    });
  }

  /// Execute API call with retry logic for rate limits
  Future<String> _executeWithRetry(Future<String> Function() apiCall, {int maxRetries = 2}) async {
    int retryCount = 0;
    
    while (retryCount <= maxRetries) {
      try {
        return await apiCall();
      } catch (e) {
        final errorString = e.toString();
        print('❌ Gemini API Error: $e');
        
        // Check for API key error
        if (errorString.contains('API_KEY') || errorString.contains('API key')) {
          return 'Please configure your Gemini API key in the .env file to enable AI chat.';
        }
        
        // Check for rate limit / quota exceeded
        if (errorString.contains('429') || 
            errorString.contains('quota') || 
            errorString.contains('rate limit') ||
            errorString.contains('Too Many Requests')) {
          
          // Extract retry time if available
          int retrySeconds = 60; // Default 60 seconds
          final retryMatch = RegExp(r'retry in (\d+\.?\d*)s', caseSensitive: false).firstMatch(errorString);
          if (retryMatch != null) {
            retrySeconds = (double.parse(retryMatch.group(1)!)).ceil();
          }
          
          if (retryCount < maxRetries) {
            print('⏳ Rate limit hit. Retrying in ${retrySeconds}s... (attempt ${retryCount + 1}/${maxRetries + 1})');
            await Future.delayed(Duration(seconds: retrySeconds));
            retryCount++;
            continue;
          } else {
            return 'I\'ve reached my rate limit for now. Please wait a minute and try again. You can check your usage at https://ai.dev/usage 😊';
          }
        }
        
        // For other errors, return friendly message
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * (retryCount + 1))); // Exponential backoff
          retryCount++;
          continue;
        }
        
        return 'I\'m having trouble connecting right now. Please try again in a moment. 😊';
      }
    }
    
    return 'I\'m having trouble connecting right now. Please try again in a moment. 😊';
  }

  /// Generate welcome message
  Future<String> generateWelcome({String? username}) async {
    final name = username ?? 'there';
    final prompt = 'Generate a warm, friendly greeting for $name as their health coach. Keep it short (1-2 sentences) and welcoming.';
    
    return _executeWithRetry(() async {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Hello $name! How are you feeling today? 👋';
    }, maxRetries: 1).catchError((e) {
      return 'Hello $name! How are you feeling today? 👋';
    });
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
    
    return _executeWithRetry(() async {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _getFallbackMoodResponse(moodLevel);
    }, maxRetries: 1).catchError((e) {
      return _getFallbackMoodResponse(moodLevel);
    });
  }

  /// Generate daily health tip
  Future<String> generateDailyTip() async {
    final prompt = 'Give a short, actionable health tip about hydration, mood, or wellness. Keep it to 1 sentence with an emoji.';
    
    return _executeWithRetry(() async {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '💧 Remember to stay hydrated throughout the day!';
    }, maxRetries: 1).catchError((e) {
      return '💧 Remember to stay hydrated throughout the day!';
    });
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
    
    return _executeWithRetry(() async {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Keep up the great work on your health journey! 🌟';
    }, maxRetries: 1).catchError((e) {
      return 'Keep up the great work on your health journey! 🌟';
    });
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }

  // Fallback responses when API fails
  String _getFallbackMoodResponse(int moodLevel) {
    if (moodLevel >= 4) {
      return 'That\'s wonderful! Keep up that positive energy! ✨';
    } else if (moodLevel == 3) {
      return 'A neutral day is okay. Small steps toward wellness count! 🌱';
    } else {
      return 'I hear you. Remember to be kind to yourself today. 💙';
    }
  }
}

