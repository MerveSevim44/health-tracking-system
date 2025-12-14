// 📁 lib/tests/gemini_test.dart
// Minimal test to verify Gemini API works without Firebase/UI
// This uses ONLY Google AI Studio (Generative Language API) with API key authentication
// NO Vertex AI, NO service accounts, NO /v1beta/ endpoints

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Test function to verify Gemini API is working with Google AI Studio
/// Expected endpoint: https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent
/// Call this from main.dart or a debug screen
Future<String> testGeminiConnection() async {
  debugPrint('═══════════════════════════════════════════════════════════');
  debugPrint('🧪 GEMINI API CONNECTION TEST - STARTING');
  debugPrint('═══════════════════════════════════════════════════════════');
  
  try {
    // ✅ CORRECT: Google AI Studio with API Key (NOT Vertex AI)
    const apiKey = 'AIzaSyBnpsgc7zFxt9Svi4vpVtnS7u0w7bgquew';
    
    debugPrint('');
    debugPrint('📋 Configuration:');
    debugPrint('   Model: gemini-2.5-flash (gemini-pro is deprecated)');
    debugPrint('   Authentication: API Key (Google AI Studio)');
    debugPrint('   API Key: ${apiKey.substring(0, 10)}...');
    debugPrint('   Expected Endpoint: /v1beta/models/gemini-2.5-flash:generateContent');
    debugPrint('   Expected Host: generativelanguage.googleapis.com');
    debugPrint('   Note: v1beta is the CORRECT endpoint for Google AI Studio');
    debugPrint('');
    
    // Initialize model with ONLY API key (no project, no location, no Vertex)
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
    
    debugPrint('✅ GenerativeModel initialized successfully');
    debugPrint('');
    
    // Simple test prompt
    final prompt = 'Reply with exactly: "Gemini API is working correctly!"';
    final content = [Content.text(prompt)];
    
    debugPrint('📤 Sending test request...');
    debugPrint('   Prompt: $prompt');
    debugPrint('');
    
    // Make the API call
    final response = await model.generateContent(content);
    
    final responseText = response.text ?? 'No response text received';
    
    debugPrint('✅ SUCCESS!');
    debugPrint('');
    debugPrint('📥 Response Details:');
    debugPrint('   Text: $responseText');
    debugPrint('   Length: ${responseText.length} characters');
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('✅ GEMINI API CONNECTION TEST - PASSED');
    debugPrint('   Endpoint: Google AI Studio (/v1/)');
    debugPrint('   Authentication: API Key');
    debugPrint('   Status: Working correctly');
    debugPrint('═══════════════════════════════════════════════════════════');
    
    return responseText;
  } catch (e, stackTrace) {
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('❌ GEMINI API CONNECTION TEST - FAILED');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('');
    debugPrint('Error Details:');
    debugPrint('   Type: ${e.runtimeType}');
    debugPrint('   Message: $e');
    debugPrint('');
    
    final errorString = e.toString();
    
    // Detailed error diagnostics
    if (errorString.contains('404') || errorString.contains('Not Found')) {
      debugPrint('🔍 Diagnosis: 404 Not Found');
      debugPrint('   This usually means:');
      debugPrint('   - Using wrong endpoint (check for /v1beta/ instead of /v1/)');
      debugPrint('   - Vertex AI is being used instead of Google AI Studio');
      debugPrint('   - Model name is incorrect');
      debugPrint('');
    } else if (errorString.contains('API_KEY') || errorString.contains('API key')) {
      debugPrint('🔍 Diagnosis: API Key Error');
      debugPrint('   - Check that API key is valid');
      debugPrint('   - Verify key is for Google AI Studio (not Vertex AI)');
      debugPrint('');
    } else if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      debugPrint('🔍 Diagnosis: Unauthorized');
      debugPrint('   - API key may be invalid or expired');
      debugPrint('   - Check permissions at https://aistudio.google.com/app/apikey');
      debugPrint('');
    }
    
    debugPrint('Stack Trace:');
    debugPrint(stackTrace.toString());
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    
    return 'Error: $e';
  }
}

/// Alternative test with different model
Future<String> testGeminiFlash() async {
  debugPrint('🧪 Testing Gemini 1.5 Flash model...');
  
  try {
    const apiKey = 'AIzaSyBnpsgc7zFxt9Svi4vpVtnS7u0w7bgquew';
    
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
    
    final response = await model.generateContent([
      Content.text('Say "Hello from Flash!"')
    ]);
    
    debugPrint('✅ Flash model response: ${response.text}');
    return response.text ?? 'No response';
  } catch (e) {
    debugPrint('❌ Flash model error: $e');
    return 'Error: $e';
  }
}

/// Run this as a standalone test
void main() async {
  await testGeminiConnection();
  debugPrint('');
  await testGeminiFlash();
}
