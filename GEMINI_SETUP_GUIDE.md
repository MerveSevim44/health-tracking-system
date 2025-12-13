# 🤖 Gemini AI Integration Guide

## ✅ Gemini AI Chat Setup

Your health tracking app now uses **Google's Gemini AI** for intelligent, personalized health coaching!

---

## 🔑 Step 1: Get Your Gemini API Key

### Option A: Using Google AI Studio (Recommended)
1. Go to: **https://makersuite.google.com/app/apikey**
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy your API key

### Option B: Using Google Cloud Console
1. Go to: **https://console.cloud.google.com/**
2. Create a new project or select existing
3. Enable **Generative Language API**
4. Go to **APIs & Services > Credentials**
5. Create **API Key**
6. Copy your API key

---

## 🔧 Step 2: Add Your API Key

### Open the file:
`lib/services/gemini_service.dart`

### Find this line (line 12):
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

### Replace with your actual key:
```dart
static const String _apiKey = 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
```

**⚠️ IMPORTANT:** 
- Never commit your API key to version control
- Keep it private and secure
- For production, use environment variables

---

## 📦 Step 3: Install Dependencies

Run this command to install the Gemini package:

```bash
flutter pub get
```

This will install:
- `google_generative_ai: ^0.4.6`

---

## 🚀 Step 4: Run Your App

```bash
flutter run
```

The AI chat will now use real Gemini AI responses!

---

## 🎯 What the AI Can Do

### 1. **Personalized Conversations**
- Responds to your messages naturally
- Remembers conversation context
- Adapts to your mood and health data

### 2. **Health Insights**
- Analyzes your mood patterns
- Reminds about hydration goals
- Encourages medication adherence
- Suggests wellness tips

### 3. **Emotional Support**
- Empathetic responses to mood check-ins
- Supportive messages when feeling down
- Celebrates your achievements
- Provides motivation

### 4. **Smart Coaching**
- Considers your current mood level
- Looks at your water intake
- Tracks medication compliance
- Gives contextual advice

---

## 💬 Example Conversations

### User: "I'm feeling stressed today"
**Gemini AI:** "I understand stress can be overwhelming. Have you tried taking a 5-minute break to practice deep breathing? Remember, you're doing great, and it's okay to take things one step at a time. 💙"

### User: "Should I drink more water?"
**Gemini AI:** "Yes! Staying hydrated is crucial for both physical and mental health. Aim for at least 8 glasses a day, and keep a water bottle nearby as a reminder. You've got this! 💧"

### User: "I forgot my medication this morning"
**Gemini AI:** "It happens! Try setting a phone reminder for tomorrow morning. Taking your medication consistently helps you feel your best. Would you like some tips for remembering? 💊"

---

## 🎨 AI Chat Features

### In the Chat Screen:
- ✅ **Real-time responses** from Gemini AI
- ✅ **Context-aware** conversations
- ✅ **Mood-based** personalization
- ✅ **Health data** integration
- ✅ **Conversation history** maintained
- ✅ **Beautiful modern UI** with dark theme

### How It Works:
1. User types a message
2. Message sent to Gemini API
3. AI analyzes message + health context
4. Personalized response generated
5. Response appears in chat bubble
6. Conversation continues naturally

---

## ⚙️ Configuration Options

### In `lib/services/gemini_service.dart`:

#### Temperature (Creativity):
```dart
temperature: 0.9, // 0.0-1.0 (higher = more creative)
```

#### Max Response Length:
```dart
maxOutputTokens: 1024, // Max words in response
```

#### Safety Settings:
```dart
safetySettings: [
  SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
  SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
]
```

---

## 🔒 Security Best Practices

### For Development:
```dart
// Current approach (simple but not secure for production)
static const String _apiKey = 'your-key-here';
```

### For Production:
Use environment variables or secure storage:

```dart
// Option 1: Environment variables
static String get _apiKey => 
    const String.fromEnvironment('GEMINI_API_KEY');

// Option 2: Flutter dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';
static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
```

---

## 🧪 Testing the AI

### Test Scenarios:

#### 1. Mood Support:
```
User: "I'm feeling anxious"
Expected: Supportive response with breathing exercise suggestion
```

#### 2. Health Advice:
```
User: "How much water should I drink?"
Expected: Personalized hydration recommendation
```

#### 3. Medication Help:
```
User: "I keep forgetting my pills"
Expected: Practical tips for medication adherence
```

#### 4. General Wellness:
```
User: "Give me a health tip"
Expected: Random wellness advice
```

---

## 🆘 Troubleshooting

### Problem: "API_KEY error"
**Solution:** 
- Check you've added your API key in `gemini_service.dart`
- Verify the key is correct (starts with "AIza")
- Make sure you ran `flutter pub get`

### Problem: "API quota exceeded"
**Solution:**
- Gemini has free tier limits
- Check usage at: https://console.cloud.google.com/
- Consider upgrading plan or implementing rate limiting

### Problem: "Network error"
**Solution:**
- Check internet connection
- Verify Firebase is connected
- Check firewall/proxy settings

### Problem: Slow responses
**Solution:**
- Normal - Gemini takes 2-5 seconds
- Loading indicator shows during wait
- Consider reducing `maxOutputTokens` for faster responses

---

## 📊 API Usage & Limits

### Free Tier (Gemini Pro):
- **60 requests per minute**
- **1,500 requests per day**
- **1 million tokens per month**

### For Most Users:
This is plenty! Each conversation uses ~100-500 tokens.

---

## 🎨 Customization Ideas

### Personality Tones:
Edit the system prompt in `initializeContext()`:

**Friendly & Casual:**
```dart
'You are MINOA, a friendly health buddy who chats casually.'
```

**Professional:**
```dart
'You are MINOA, a professional health advisor.'
```

**Motivational:**
```dart
'You are MINOA, an energetic fitness coach who motivates users.'
```

### Response Length:
```dart
maxOutputTokens: 512,  // Shorter responses
maxOutputTokens: 2048, // Longer, detailed responses
```

---

## 🚀 Advanced Features

### Add Image Analysis (Future):
```dart
// Use gemini-pro-vision model
final model = GenerativeModel(
  model: 'gemini-pro-vision',
  apiKey: _apiKey,
);
```

### Multi-language Support:
```dart
final prompt = 'Respond in Turkish: $userMessage';
```

### Mood Analysis:
```dart
final sentiment = await analyzeSentiment(userMessage);
```

---

## 📝 Quick Reference

### Files Modified:
1. ✅ `pubspec.yaml` - Added Gemini package
2. ✅ `lib/services/gemini_service.dart` - NEW file (AI service)
3. ✅ `lib/services/ai_coach_service.dart` - Original (still works as fallback)

### To Use Gemini:
```dart
// In any screen
final gemini = GeminiService();
gemini.initializeContext(username: 'Alice');
final response = await gemini.sendMessage('How are you?');
```

### Current Integration:
The chat screen automatically uses Gemini when:
- API key is configured
- Package is installed
- Internet is available

---

## ✅ Setup Checklist

- [ ] Get Gemini API key from Google
- [ ] Add key to `lib/services/gemini_service.dart`
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`
- [ ] Test chat with "Hello"
- [ ] Verify AI responds intelligently
- [ ] Test mood-based responses
- [ ] Check conversation memory works

---

## 🎉 You're All Set!

Your AI health coach is now powered by Google's Gemini AI!

**Next Steps:**
1. Add your API key
2. Run `flutter pub get`
3. Test the chat
4. Enjoy intelligent, personalized health coaching!

---

**Resources:**
- Gemini API Docs: https://ai.google.dev/docs
- Get API Key: https://makersuite.google.com/app/apikey
- Pricing: https://ai.google.dev/pricing

**Your users will now have real AI-powered conversations!** 🤖✨

