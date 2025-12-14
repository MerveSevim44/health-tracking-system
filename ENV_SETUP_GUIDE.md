# 🔐 Environment Variables Setup Guide

## ✅ Secure Configuration with .env File

Your app now uses a `.env` file to store all sensitive information like API keys and Firebase credentials. This is much more secure than hardcoding them in your source code!

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Create .env File

In your project root directory (same folder as `pubspec.yaml`), create a new file named **`.env`** (note the dot at the start).

**Location:**
```
health-tracking-system/
├── lib/
├── android/
├── ios/
├── pubspec.yaml
└── .env  ← Create this file here!
```

---

### Step 2: Copy Template Content

Open the file `env_template.txt` in your project and copy its entire content, OR copy this template:

```env
# 🔐 Environment Variables

# ====================================
# GEMINI AI CONFIGURATION
# ====================================
GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE

# ====================================
# FIREBASE CONFIGURATION
# ====================================
FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY_HERE
FIREBASE_APP_ID=YOUR_FIREBASE_APP_ID_HERE
FIREBASE_MESSAGING_SENDER_ID=YOUR_MESSAGING_SENDER_ID_HERE
FIREBASE_PROJECT_ID=YOUR_PROJECT_ID_HERE
FIREBASE_AUTH_DOMAIN=YOUR_AUTH_DOMAIN_HERE
FIREBASE_STORAGE_BUCKET=YOUR_STORAGE_BUCKET_HERE
FIREBASE_DATABASE_URL=https://your-project-default-rtdb.europe-west1.firebasedatabase.app

# ====================================
# APP CONFIGURATION
# ====================================
APP_NAME=Health Tracking System
DEFAULT_WATER_GOAL=2000
DEFAULT_MOOD_REMINDER=true
```

Paste this into your new `.env` file.

---

### Step 3: Add Your API Keys

Now replace the placeholder values with your actual credentials:

#### 🤖 **Gemini API Key:**
1. Go to: https://makersuite.google.com/app/apikey
2. Sign in and create API key
3. Copy the key (looks like: `AIzaSyB...`)
4. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual key

**Example:**
```env
GEMINI_API_KEY=AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### 🔥 **Firebase Configuration:**
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project
3. Click **⚙️ Settings** > **Project Settings**
4. Scroll to **"Your apps"** section
5. Select your Web app or create one
6. Copy the config values

**Example:**
```env
FIREBASE_API_KEY=AIzaSymy_firebase_key_here
FIREBASE_APP_ID=1:123456789:web:abcdef123456
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_PROJECT_ID=health-tracking-system-700bf
FIREBASE_AUTH_DOMAIN=health-tracking-system-700bf.firebaseapp.com
FIREBASE_STORAGE_BUCKET=health-tracking-system-700bf.appspot.com
```

#### 🗄️ **Firebase Database URL:**
1. Go to Firebase Console
2. Click **Realtime Database** in left menu
3. Copy the database URL from the top
4. Paste it in `.env`

**Example:**
```env
FIREBASE_DATABASE_URL=https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app
```

---

### Step 4: Save and Run

1. **Save** your `.env` file
2. Run the app:
```bash
flutter pub get
flutter run
```

**Done!** Your app now loads all secrets from `.env` securely! 🎉

---

## 📁 File Structure

```
health-tracking-system/
├── .env                      ← Your actual secrets (NOT committed)
├── env_template.txt          ← Template for reference (committed)
├── .gitignore                ← Includes .env (so it's not committed)
├── pubspec.yaml              ← Includes .env as asset
└── lib/
    ├── main.dart             ← Loads .env on startup
    └── services/
        └── gemini_service.dart  ← Uses .env variables
```

---

## 🔒 Security Features

### ✅ What's Protected:
- **Gemini API Key** - Loaded from .env
- **Firebase API Key** - Can be loaded from .env (future)
- **Database URLs** - Can be loaded from .env (future)
- **Any custom secrets** - Add to .env anytime

### ✅ Why This is Secure:
1. **Not in source code** - Secrets never in git history
2. **Easy to rotate** - Change keys without code changes
3. **Environment-specific** - Different .env for dev/prod
4. **Gitignored** - .env is automatically ignored by git

### ⚠️ Important Notes:
- **NEVER commit .env** to git (it's in .gitignore)
- **Share template only** (env_template.txt is safe to share)
- **Each developer needs their own .env** with their keys
- **Backup your .env** somewhere safe (not in git!)

---

## 🎯 How It Works

### In Code:
```dart
// Old way (INSECURE):
static const String apiKey = 'AIzaSyB...'; // ❌ Bad!

// New way (SECURE):
import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; // ✅ Good!
```

### On App Startup:
```dart
void main() async {
  // Load .env file before anything else
  await dotenv.load(fileName: ".env");
  
  // Now all dotenv.env['KEY'] calls work!
  runApp(MyApp());
}
```

---

## 🧪 Testing Your Setup

### Test 1: Check .env Loaded
Add this temporary code in `main.dart`:
```dart
void main() async {
  await dotenv.load(fileName: ".env");
  
  // Print to verify (REMOVE after testing!)
  print('Gemini Key loaded: ${dotenv.env['GEMINI_API_KEY']?.isNotEmpty}');
  
  runApp(MyApp());
}
```

**Expected output:** `Gemini Key loaded: true`

### Test 2: Test AI Chat
1. Run your app
2. Go to AI Coach tab
3. Send a message
4. If AI responds → ✅ Working!
5. If error → Check your key in .env

---

## 📝 Environment Variables Reference

### Current Variables:

| Variable | Required | Purpose | Where to Get |
|----------|----------|---------|--------------|
| `GEMINI_API_KEY` | ✅ Yes | AI chat responses | https://makersuite.google.com/app/apikey |
| `FIREBASE_API_KEY` | ⏳ Future | Firebase web config | Firebase Console |
| `FIREBASE_APP_ID` | ⏳ Future | Firebase app ID | Firebase Console |
| `FIREBASE_PROJECT_ID` | ⏳ Future | Firebase project | Firebase Console |
| `FIREBASE_DATABASE_URL` | ⏳ Future | Realtime DB URL | Firebase Console |
| `APP_NAME` | ❌ Optional | App display name | Custom |
| `DEFAULT_WATER_GOAL` | ❌ Optional | Default goal (ml) | Custom |

---

## 🆘 Troubleshooting

### Problem: ".env file not found"

**Cause:** File not in root directory or wrong name

**Solution:**
1. Make sure file is named exactly `.env` (with dot)
2. Place in project root (same level as `pubspec.yaml`)
3. Not in `lib/` folder!

---

### Problem: "GEMINI_API_KEY is empty"

**Cause:** Key not added to .env or typo in variable name

**Solution:**
1. Open `.env` file
2. Check line: `GEMINI_API_KEY=your_actual_key`
3. No spaces around `=`
4. No quotes around value
5. Save file
6. Restart app

---

### Problem: "Unable to load asset .env"

**Cause:** .env not added to pubspec.yaml assets

**Solution:**
Check `pubspec.yaml` includes:
```yaml
flutter:
  assets:
    - .env
```

Then run:
```bash
flutter clean
flutter pub get
flutter run
```

---

### Problem: API still not working

**Cause:** Invalid API key

**Solution:**
1. Get a fresh API key from https://makersuite.google.com/app/apikey
2. Copy it carefully (no extra spaces)
3. Paste in `.env`: `GEMINI_API_KEY=AIzaSyB...`
4. Save and restart app

---

## 🔄 Different Environments

### For Multiple Environments:

You can have different .env files:

```
.env          ← Default (development)
.env.prod     ← Production
.env.staging  ← Staging
```

Load specific one:
```dart
await dotenv.load(fileName: ".env.prod");
```

---

## 📋 Best Practices

### ✅ DO:
- Keep `.env` file in project root
- Add all secrets to `.env`
- Backup `.env` securely (not in git)
- Use descriptive variable names
- Document all variables in `env_template.txt`

### ❌ DON'T:
- Commit `.env` to git
- Share `.env` file publicly
- Hardcode secrets in source code
- Put `.env` in `lib/` folder
- Add quotes around values (unless needed)

---

## 🎊 You're All Set!

Your app now securely loads:
- ✅ Gemini API key from `.env`
- ✅ All secrets kept out of source code
- ✅ Easy to update without code changes
- ✅ Safe to share code publicly

**Your secrets are now secure!** 🔒✨

---

## 📚 Additional Resources

- **flutter_dotenv Package:** https://pub.dev/packages/flutter_dotenv
- **Gemini API Keys:** https://makersuite.google.com/app/apikey
- **Firebase Console:** https://console.firebase.google.com/
- **Security Best Practices:** https://flutter.dev/docs/deployment/security

---

## ✅ Quick Checklist

- [ ] Created `.env` file in project root
- [ ] Copied template from `env_template.txt`
- [ ] Added Gemini API key
- [ ] Added Firebase credentials (optional)
- [ ] Saved `.env` file
- [ ] Ran `flutter pub get`
- [ ] Tested app - AI chat works
- [ ] Verified `.env` is in `.gitignore`
- [ ] Did NOT commit `.env` to git

---

**Need help?** Check the troubleshooting section above or review `env_template.txt` for the correct format!




