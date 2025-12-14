// List available models for the API key
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> listAvailableModels() async {
  print('═══════════════════════════════════════════════════════════');
  print('📋 LISTING AVAILABLE MODELS');
  print('═══════════════════════════════════════════════════════════');
  print('');
  
  const apiKey = 'AIzaSyBnpsgc7zFxt9Svi4vpVtnS7u0w7bgquew';
  
  // List models from v1beta
  print('📤 Querying v1beta/models...');
  final urlV1Beta = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey'
  );
  
  try {
    final response = await http.get(urlV1Beta);
    
    print('Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = data['models'] as List;
      
      print('');
      print('✅ Found ${models.length} models in v1beta:');
      print('');
      
      for (final model in models) {
        final name = model['name'] as String;
        final displayName = model['displayName'] as String?;
        final supportedMethods = (model['supportedGenerationMethods'] as List?)?.join(', ') ?? 'N/A';
        
        print('Model: $name');
        print('  Display Name: $displayName');
        print('  Supported Methods: $supportedMethods');
        print('');
      }
    } else {
      print('❌ Failed to list models');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  print('═══════════════════════════════════════════════════════════');
  
  // Also try v1
  print('📤 Querying v1/models...');
  final urlV1 = Uri.parse(
    'https://generativelanguage.googleapis.com/v1/models?key=$apiKey'
  );
  
  try {
    final response = await http.get(urlV1);
    
    print('Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = data['models'] as List;
      
      print('');
      print('✅ Found ${models.length} models in v1:');
      print('');
      
      for (final model in models) {
        final name = model['name'] as String;
        final displayName = model['displayName'] as String?;
        final supportedMethods = (model['supportedGenerationMethods'] as List?)?.join(', ') ?? 'N/A';
        
        print('Model: $name');
        print('  Display Name: $displayName');
        print('  Supported Methods: $supportedMethods');
        print('');
      }
    } else {
      print('❌ Failed to list models');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  print('═══════════════════════════════════════════════════════════');
}

void main() async {
  await listAvailableModels();
}
