// Test to verify API key is valid by making a direct HTTP request
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testApiKeyDirect() async {
  print('═══════════════════════════════════════════════════════════');
  print('🔑 TESTING API KEY DIRECTLY');
  print('═══════════════════════════════════════════════════════════');
  print('');
  
  const apiKey = 'AIzaSyBnpsgc7zFxt9Svi4vpVtnS7u0w7bgquew';
  
  // Test with v1beta endpoint (what the SDK uses)
  final urlV1Beta = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey'
  );
  
  print('📤 Testing with v1beta endpoint...');
  print('   URL: ${urlV1Beta.toString().replaceAll(apiKey, 'API_KEY')}');
  print('');
  
  try {
    final response = await http.post(
      urlV1Beta,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Say "Hello from v1beta!"'}
            ]
          }
        ]
      }),
    );
    
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      print('✅ SUCCESS with v1beta!');
      print('   Response: $text');
    } else {
      print('❌ Failed with v1beta');
      print('   Error: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  print('');
  print('═══════════════════════════════════════════════════════════');
  
  // Also test v1 endpoint
  final urlV1 = Uri.parse(
    'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash-latest:generateContent?key=$apiKey'
  );
  
  print('📤 Testing with v1 endpoint...');
  print('   URL: ${urlV1.toString().replaceAll(apiKey, 'API_KEY')}');
  print('');
  
  try {
    final response = await http.post(
      urlV1,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Say "Hello from v1!"'}
            ]
          }
        ]
      }),
    );
    
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      print('✅ SUCCESS with v1!');
      print('   Response: $text');
    } else {
      print('❌ Failed with v1');
      print('   Error: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  print('═══════════════════════════════════════════════════════════');
}

void main() async {
  await testApiKeyDirect();
}
