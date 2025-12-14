# 🚀 Quick Start Guide - MINOA Health Tracking System

## 📋 Prerequisites

Before you begin, ensure you have:
1. ✅ Flutter SDK installed (version 3.9.2 or higher)
2. ✅ Android Studio or VS Code with Flutter extensions
3. ✅ An emulator or physical device
4. ✅ Firebase project configured (if using backend features)

## 🎯 Installation & Setup

### Step 1: Verify Flutter Installation
```bash
flutter --version
flutter doctor
```

If Flutter is not installed, download it from: https://docs.flutter.dev/get-started/install

### Step 2: Install Dependencies
```bash
cd health-tracking-system
flutter pub get
```

### Step 3: Run the App
```bash
flutter run
```

## 🔥 Development Mode (Auto-Reload)

Once the app is running, Flutter's hot reload feature automatically applies changes:

### During Development:
1. **Make changes** to any `.dart` file
2. **Save the file** (Ctrl+S / Cmd+S)
3. **Press `r`** in the terminal to hot reload
   - Changes appear instantly (< 1 second)
   - App state is preserved
4. **Press `R`** if you need a full restart (rare)

### IDE Integration:
- **VS Code**: Changes hot reload automatically on save
- **Android Studio**: Click the lightning bolt icon or save

### What Hot Reload Updates:
✅ UI changes (colors, layouts, widgets)
✅ Text content
✅ Method implementations
✅ Most code changes

❌ Won't hot reload:
- New file additions (use `R`)
- App initialization changes (use `R`)
- Native code modifications (full rebuild needed)

## 🎨 New Design Features

### Landing Page
- **Swipeable sections**: Swipe left/right to explore features
- **Auto-rotation**: Features automatically cycle every 4 seconds
- **Page indicators**: Tap to jump to any section
- **CTA buttons**: "Get Started" or "Login"

### Login Screen
- **Glassmorphic design**: Modern frosted glass effect
- **Animated background**: Floating gradient orbs
- **Password visibility**: Toggle to show/hide password
- **Forgot password**: Built-in password reset

### Register Screen
- **3-field signup**: Username, Email, Password
- **Terms checkbox**: Required before signup
- **Real-time validation**: Instant feedback
- **Smooth transitions**: Navigate to login after success

## 📱 Navigation Flow

```
Landing Page → Login/Register → Home Dashboard
     ↓              ↓                 ↓
  Skip →        Sign In/Up →    Main Features
```

## 🛠️ Troubleshooting

### Hot Reload Not Working?
- Try hot restart: Press `R`
- Check console for errors
- Ensure file is saved

### App Won't Run?
```bash
# Clean build cache
flutter clean
flutter pub get
flutter run
```

### Firebase Errors?
- Check `firebase_options.dart` exists
- Verify `google-services.json` is in `android/app/`
- Ensure Firebase project is configured

### Performance Issues?
- Run in release mode: `flutter run --release`
- Enable performance overlay: Press `P` in debug mode

## 🎯 Testing the New Designs

### Test Landing Page:
1. Run the app
2. Observe the splash screen
3. Land on the new landing page
4. Swipe through all 4 sections
5. Tap different page indicators
6. Try "Get Started" button → Goes to Register
7. Try "I Already Have an Account" → Goes to Login

### Test Login:
1. Navigate to login screen
2. Test empty field validation
3. Try password visibility toggle
4. Test "Forgot Password" feature
5. Use "Sign Up" link to switch to Register

### Test Register:
1. Navigate to register screen
2. Fill all three fields
3. Test terms checkbox requirement
4. Try submitting with short password (< 6 chars)
5. Successful signup redirects to Login

## 📊 App Structure

```
Launch → Splash Screen → Landing Page
                              ↓
                    Login or Register
                              ↓
                        Home Screen
                              ↓
                    ┌─────────┴─────────┐
                    ↓                   ↓
              Mood Tracking      Water Tracking
                    ↓                   ↓
            Medication Tracker    AI Coach
```

## 💡 Pro Tips

1. **Keep the app running**: Don't stop/restart for UI changes
2. **Use hot reload (`r`)**: Instant updates without losing state
3. **Check console**: Watch for helpful error messages
4. **Use DevTools**: Press `v` to open Flutter DevTools
5. **Multiple devices**: Run on several devices simultaneously

## 🎨 Customization

Want to customize the design? Edit these files:
- `lib/screens/landing_page.dart` - Landing page design
- `lib/screens/login_screen.dart` - Login screen
- `lib/screens/register_screen.dart` - Register screen

Colors are defined in the `AppColors` class at the top of each file.

## 📝 Common Commands

```bash
# Run in debug mode (hot reload enabled)
flutter run

# Run in release mode (optimized, no hot reload)
flutter run --release

# Run on specific device
flutter run -d android
flutter run -d chrome

# View all connected devices
flutter devices

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## 🆘 Need Help?

- Check [DEV_MODE_GUIDE.md](DEV_MODE_GUIDE.md) for detailed dev mode info
- See [README.md](README.md) for full documentation
- Flutter docs: https://docs.flutter.dev
- Firebase docs: https://firebase.google.com/docs

---

**Happy coding! 🎉**

The new designs are ready to use with hot reload enabled by default in Flutter!





