# ⚡ Quick .env Setup (2 Minutes!)

## Step 1: Create .env File

In your project root folder (where `pubspec.yaml` is), create a file named `.env`

---

## Step 2: Add This Content

Copy and paste into your `.env` file:

```env
GEMINI_API_KEY=YOUR_KEY_HERE
FIREBASE_DATABASE_URL=https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app
APP_NAME=Health Tracking System
DEFAULT_WATER_GOAL=2000
```

---

## Step 3: Get Your Gemini API Key

1. Visit: **https://makersuite.google.com/app/apikey**
2. Sign in with Google
3. Click "Create API Key"
4. Copy the key

---

## Step 4: Add Your Key

Replace `YOUR_KEY_HERE` in `.env` with your actual key:

```env
GEMINI_API_KEY=AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Step 5: Run

```bash
flutter pub get
flutter run
```

---

## ✅ Done!

Your app now loads all secrets from `.env` securely!

**Test it:** Open AI Coach and send a message!

---

**Need help?** See `ENV_SETUP_GUIDE.md` for detailed instructions.




