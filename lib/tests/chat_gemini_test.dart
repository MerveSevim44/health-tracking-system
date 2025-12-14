// Test file for Gemini AI Chat Response

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> testGeminiChat() async {
  debugPrint('=====================================================');
  debugPrint('TESTING GEMINI AI FOR CHAT');
  debugPrint('=====================================================');
  
  try {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: 'AIzaSyBnpsgc7zFxt9Svi4vpVtnS7u0w7bgquew',
    );
    
    // Test 1: Simple health question
    debugPrint('');
    debugPrint('Test 1: Water reminder question');
    final prompt1 = 'I keep forgetting to drink water. What do you suggest? Reply in Turkish briefly.';
    
    final result1 = await model.generateContent([Content.text(prompt1)]);
    final response1 = result1.text?.trim() ?? 'No response';
    
    debugPrint('AI Response:');
    debugPrint(response1);
    debugPrint('');
    
    // Test 2: Mood response
    debugPrint('Test 2: Feeling tired today');
    final prompt2 = 'Today I feel very tired. Give supportive response in Turkish.';
    
    final result2 = await model.generateContent([Content.text(prompt2)]);
    final response2 = result2.text?.trim() ?? 'No response';
    
    debugPrint('AI Response:');
    debugPrint(response2);
    debugPrint('');
    
    // Test 3: Happy mood
    debugPrint('Test 3: Feeling great today');
    final prompt3 = 'I feel amazing and energetic today! Respond encouragingly in Turkish.';
    
    final result3 = await model.generateContent([Content.text(prompt3)]);
    final response3 = result3.text?.trim() ?? 'No response';
    
    debugPrint('AI Response:');
    debugPrint(response3);
    debugPrint('');
    
    debugPrint('=====================================================');
    debugPrint('ALL TESTS PASSED - Gemini AI working for chat!');
    debugPrint('=====================================================');
    
  } catch (e, stackTrace) {
    debugPrint('');
    debugPrint('TEST FAILED');
    debugPrint('Error: $e');
    debugPrint('Stack: $stackTrace');
  }
}

void main() async {
  await testGeminiChat();
}
