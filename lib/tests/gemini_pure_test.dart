// 📁 lib/tests/gemini_pure_test.dart
// Pure Dart test (NO Flutter dependencies) to verify Gemini API
// This uses ONLY Google AI Studio (Generative Language API) with API key authentication
// NO Vertex AI, NO service accounts, NO /v1beta/ endpoints

import 'package:google_generative_ai/google_generative_ai.dart';

/// Test function to verify Gemini API is working with Google AI Studio
/// Expected endpoint: https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent
Future<String> testGeminiConnection() async {
  print('═══════════════════════════════════════════════════════════');
  print('🧪 GEMINI API CONNECTION TEST - STARTING');
  print('═══════════════════════════════════════════════════════════');
  
  try {
    // ✅ CORRECT: Google AI Studio with API Key (NOT Vertex AI)
    const apiKey = 'AIzaSyBnpsgc7zFxt9Svi4vpVtnS7u0w7bgquew';
    
    print('');
    print('📋 Configuration:');
    print('   Model: gemini-2.5-flash (gemini-pro is deprecated)');
    print('   Authentication: API Key (Google AI Studio)');
    print('   API Key: ${apiKey.substring(0, 10)}...');
    print('   Expected Endpoint: /v1beta/models/gemini-2.5-flash:generateContent');
    print('   Expected Host: generativelanguage.googleapis.com');
    print('   Note: v1beta is the CORRECT endpoint for Google AI Studio');
    print('');
    
    // Initialize model with ONLY API key (no project, no location, no Vertex)
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
    
    print('✅ GenerativeModel initialized successfully');
    print('');
    
    // Simple test prompt
    final prompt = 'Reply with exactly: "Gemini API is working correctly!"';
    final content = [Content.text(prompt)];
    
    print('📤 Sending test request...');
    print('   Prompt: $prompt');
    print('');
    
    // Make the API call
    final response = await model.generateContent(content);
    
    final responseText = response.text ?? 'No response text received';
    
    print('✅ SUCCESS!');
    print('');
    print('📥 Response Details:');
    print('   Text: $responseText');
    print('   Length: ${responseText.length} characters');
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('✅ GEMINI API CONNECTION TEST - PASSED');
    print('   Endpoint: Google AI Studio (/v1/)');
    print('   Authentication: API Key');
    print('   Status: Working correctly');
    print('═══════════════════════════════════════════════════════════');
    
    return responseText;
  } catch (e, stackTrace) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('❌ GEMINI API CONNECTION TEST - FAILED');
    print('═══════════════════════════════════════════════════════════');
    print('');
    print('Error Details:');
    print('   Type: ${e.runtimeType}');
    print('   Message: $e');
    print('');
    
    final errorString = e.toString();
    
    // Detailed error diagnostics
    if (errorString.contains('404') || errorString.contains('Not Found')) {
      print('🔍 Diagnosis: 404 Not Found');
      print('   This usually means:');
      print('   - Using wrong endpoint (check for /v1beta/ instead of /v1/)');
      print('   - Vertex AI is being used instead of Google AI Studio');
      print('   - Model name is incorrect');
      print('');
    } else if (errorString.contains('API_KEY') || errorString.contains('API key')) {
      print('🔍 Diagnosis: API Key Error');
      print('   - Check that API key is valid');
      print('   - Verify key is for Google AI Studio (not Vertex AI)');
      print('');
    } else if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      print('🔍 Diagnosis: Unauthorized');
      print('   - API key may be invalid or expired');
      print('   - Check permissions at https://aistudio.google.com/app/apikey');
      print('');
    }
    
    print('Stack Trace:');
    print(stackTrace.toString());
    print('');
    print('═══════════════════════════════════════════════════════════');
    
    return 'Error: $e';
  }
}

/// Test different model names to find what works
Future<void> testDifferentModels() async {
  print('');
  print('═══════════════════════════════════════════════════════════');
  print('🔍 TESTING DIFFERENT MODEL NAMES');
  print('═══════════════════════════════════════════════════════════');
  print('');
  
  const apiKey = 'AIzaSyBnpsgc7zFxt9Svi4vpVtnS7u0w7bgquew';
  final modelNames = [
    'gemini-2.5-flash',
    'gemini-2.5-pro',
    'gemini-2.0-flash',
    'gemini-flash-latest',
    'gemini-pro-latest',
  ];
  
  for (final modelName in modelNames) {
    print('Testing model: $modelName');
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
      );
      
      final response = await model.generateContent([
        Content.text('Say "Success"')
      ]);
      
      print('✅ SUCCESS with $modelName: ${response.text}');
      print('');
      return; // Exit on first success
    } catch (e) {
      print('❌ Failed with $modelName: ${e.toString().split('\n').first}');
      print('');
    }
  }
  
  print('All models failed!');
}

/// Run this as a standalone test
void main() async {
  await testGeminiConnection();
  await testDifferentModels();
}
