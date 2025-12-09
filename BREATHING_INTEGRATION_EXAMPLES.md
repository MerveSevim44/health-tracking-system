# 🚀 Quick Integration Guide - Breathing Exercise

## ⚡ Quick Start (3 Steps)

### Step 1: Navigate to Breathing Screen
Add a button anywhere in your app:

```dart
// From any screen
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/breathing');
  },
  child: Text('Start Breathing'),
)
```

### Step 2: Add to Bottom Navigation
If you have a bottom nav bar, add this icon:

```dart
BottomNavigationBarItem(
  icon: Icon(Icons.spa_rounded),
  label: 'Breathing',
)

// In onTap:
case 2: // Breathing tab
  Navigator.pushNamed(context, '/breathing');
  break;
```

### Step 3: Test It!
```bash
flutter run
```

---

## 🔗 Integration Examples

### Example 1: Add to Home Screen Card
```dart
// lib/screens/home_screen.dart

Card(
  child: ListTile(
    leading: Icon(Icons.spa, color: Colors.blue),
    title: Text('Breathing Exercise'),
    subtitle: Text('Reduce stress and anxiety'),
    trailing: Icon(Icons.arrow_forward_ios),
    onTap: () => Navigator.pushNamed(context, '/breathing'),
  ),
)
```

### Example 2: Add to Mood Selection
```dart
// After mood selection, offer breathing exercise
void onMoodSelected(String mood) {
  if (mood == 'anxious' || mood == 'stressed') {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Feeling $mood?'),
        content: Text('Try a breathing exercise to calm down.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/breathing');
            },
            child: Text('Start Breathing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Now'),
          ),
        ],
      ),
    );
  }
}
```

### Example 3: Scheduled Reminder
```dart
// Show breathing reminder at specific times
void checkBreathingReminder() {
  final hour = DateTime.now().hour;
  
  if (hour == 12 || hour == 18) { // Noon and 6 PM
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Time for your breathing exercise!'),
        action: SnackBarAction(
          label: 'Start',
          onPressed: () => Navigator.pushNamed(context, '/breathing'),
        ),
        duration: Duration(seconds: 10),
      ),
    );
  }
}
```

---

## 🎨 Customization Recipes

### Recipe 1: Change Flower Color to Purple
```dart
// lib/screens/breathing_exercise_screen.dart
// Line ~50 (inside build method)

final flowerColor = isDarkMode
    ? const Color(0xFFB39DDB) // Lavender for dark
    : const Color(0xFF9575CD); // Purple for light
```

### Recipe 2: Make Animation Slower (Relaxing)
```dart
// lib/screens/breathing_exercise_screen.dart
// Line ~87 (BreathingFlowerAnimation widget)

breathDuration: const Duration(seconds: 8), // Was 5, now 8
```

### Recipe 3: Add "Joy" Emotion
```dart
// lib/widgets/breathing/emotion_chip.dart
// Line ~18 (emotions list)

final emotions = ['Anger', 'Anxiety', 'Stress', 'Sadness', 'Joy'];
```

### Recipe 4: Add 10-Minute Option
```dart
// lib/widgets/breathing/time_selector.dart
// Line ~18 (durations list)

final durations = [1, 2, 3, 4, 5, 6, 10];
```

### Recipe 5: Custom Button Text
```dart
// lib/screens/breathing_exercise_screen.dart
// Line ~152 (BreathingStartButton widget)

text: _isBreathing ? 'Pause' : 'Begin Exercise',
```

---

## 🎯 Advanced Integration Patterns

### Pattern 1: Track Breathing Sessions
```dart
class BreathingExerciseScreen extends StatefulWidget {
  // ... existing code ...
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  int _sessionCount = 0;
  int _totalMinutes = 0;
  
  void _startBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _sessionCount++;
        _totalMinutes += _selectedMinutes;
        // Save to database or shared preferences
      }
    });
  }
  
  // Show stats somewhere in UI:
  Text('Sessions completed: $_sessionCount'),
  Text('Total time: $_totalMinutes minutes'),
}
```

### Pattern 2: Connect to Analytics
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

void _startBreathing() {
  setState(() {
    _isBreathing = !_isBreathing;
    
    if (_isBreathing) {
      // Log to Firebase Analytics
      FirebaseAnalytics.instance.logEvent(
        name: 'breathing_started',
        parameters: {
          'emotion': _selectedEmotion,
          'duration': _selectedMinutes,
        },
      );
    }
  });
}
```

### Pattern 3: Add Sound Effects
```dart
import 'package:audioplayers/audioplayers.dart';

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  final AudioPlayer _player = AudioPlayer();
  
  void _startBreathing() async {
    setState(() {
      _isBreathing = !_isBreathing;
    });
    
    if (_isBreathing) {
      await _player.play(AssetSource('sounds/breath_in.mp3'));
    } else {
      await _player.stop();
    }
  }
  
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
```

### Pattern 4: Add Haptic Feedback
```dart
import 'package:flutter/services.dart';

void _startBreathing() {
  setState(() {
    _isBreathing = !_isBreathing;
  });
  
  if (_isBreathing) {
    // Vibrate on start
    HapticFeedback.mediumImpact();
    
    // Optional: Pulse vibration with breathing
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_isBreathing) {
        timer.cancel();
      } else {
        HapticFeedback.lightImpact();
      }
    });
  }
}
```

---

## 📱 Platform-Specific Adjustments

### iOS-Specific:
```dart
// Add to Info.plist for haptics
<key>UIApplicationSupportsIndirectInputEvents</key>
<true/>

// Safe area adjustments
SafeArea(
  child: BreathingExerciseScreen(),
  minimum: EdgeInsets.only(
    top: Platform.isIOS ? 20 : 0,
  ),
)
```

### Android-Specific:
```dart
// Enable Material You colors (Android 12+)
ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
  // ... rest of theme
)
```

---

## 🔔 Notification Integration

### Daily Reminder Setup:
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void scheduleBreathingReminder() {
  FlutterLocalNotificationsPlugin notifications = 
      FlutterLocalNotificationsPlugin();
  
  // Schedule daily at 12:00 PM
  notifications.zonedSchedule(
    0,
    'Breathing Break',
    'Take a moment to breathe and relax',
    _nextInstanceOf12PM(),
    NotificationDetails(
      android: AndroidNotificationDetails(
        'breathing_channel',
        'Breathing Reminders',
        channelDescription: 'Daily breathing exercise reminders',
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

TZDateTime _nextInstanceOf12PM() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    12, // 12 PM
  );
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(Duration(days: 1));
  }
  return scheduledDate;
}
```

---

## 🎨 Theme Customization Examples

### Custom Theme Colors:
```dart
// Create a custom breathing theme
final breathingTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF6B8EFF),
    secondary: Color(0xFF4CAF50),
    background: Color(0xFFFBFBFB),
  ),
);

// Apply to breathing screen only
MaterialApp(
  theme: breathingTheme,
  home: BreathingExerciseScreen(),
)
```

### Gradient Variations:
```dart
// Rainbow gradient
LinearGradient(
  colors: [
    Color(0xFFFF6B6B), // Red
    Color(0xFFFFD93D), // Yellow
    Color(0xFF6BCF7F), // Green
    Color(0xFF4D96FF), // Blue
  ],
)

// Sunset gradient
LinearGradient(
  colors: [
    Color(0xFFFF6B9D), // Pink
    Color(0xFFFFA06B), // Orange
  ],
)
```

---

## 🧪 Testing Snippets

### Widget Test:
```dart
// test/breathing_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_care/screens/breathing_exercise_screen.dart';

void main() {
  testWidgets('Breathing screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: BreathingExerciseScreen()),
    );
    
    expect(find.text('Breathing'), findsOneWidget);
    expect(find.text('Start breathing'), findsOneWidget);
  });
  
  testWidgets('Emotion selection works', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: BreathingExerciseScreen()),
    );
    
    await tester.tap(find.text('Anxiety'));
    await tester.pump();
    
    // Verify Anxiety is now selected
    // (Add visual verification here)
  });
}
```

### Integration Test:
```dart
// integration_test/breathing_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_care/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete breathing session', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Navigate to breathing
    await tester.tap(find.byIcon(Icons.spa_rounded));
    await tester.pumpAndSettle();
    
    // Select emotion
    await tester.tap(find.text('Stress'));
    await tester.pump();
    
    // Select time
    await tester.tap(find.text('2 min'));
    await tester.pump();
    
    // Start breathing
    await tester.tap(find.text('Start breathing'));
    await tester.pump();
    
    expect(find.text('Stop breathing'), findsOneWidget);
  });
}
```

---

## 📊 State Management Integration

### Provider Pattern:
```dart
// Create a breathing state provider
class BreathingState extends ChangeNotifier {
  String _selectedEmotion = 'Anger';
  int _selectedMinutes = 3;
  bool _isBreathing = false;
  int _totalSessions = 0;
  
  String get selectedEmotion => _selectedEmotion;
  int get selectedMinutes => _selectedMinutes;
  bool get isBreathing => _isBreathing;
  int get totalSessions => _totalSessions;
  
  void selectEmotion(String emotion) {
    _selectedEmotion = emotion;
    notifyListeners();
  }
  
  void selectDuration(int minutes) {
    _selectedMinutes = minutes;
    notifyListeners();
  }
  
  void toggleBreathing() {
    _isBreathing = !_isBreathing;
    if (_isBreathing) _totalSessions++;
    notifyListeners();
  }
}

// Use in screen:
class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    final breathingState = Provider.of<BreathingState>(context);
    
    return Scaffold(
      body: Column(
        children: [
          EmotionPillSelector(
            selectedEmotion: breathingState.selectedEmotion,
            onEmotionSelected: breathingState.selectEmotion,
          ),
          // ... rest of UI
        ],
      ),
    );
  }
}
```

### Riverpod Pattern:
```dart
final breathingProvider = StateNotifierProvider<BreathingNotifier, BreathingState>((ref) {
  return BreathingNotifier();
});

// Use in screen:
final state = ref.watch(breathingProvider);
```

---

## 🎯 Useful Snippets Library

### Snippet 1: Show Completion Dialog
```dart
void _onBreathingComplete() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.celebration, color: Colors.green),
          SizedBox(width: 8),
          Text('Well Done!'),
        ],
      ),
      content: Text(
        'You completed a $_selectedMinutes minute breathing session.\n\n'
        'Emotion targeted: $_selectedEmotion\n\n'
        'How do you feel now?'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Better'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _startBreathing(); // Start another session
          },
          child: Text('Continue'),
        ),
      ],
    ),
  );
}
```

### Snippet 2: Progress Indicator
```dart
// Show breathing progress
if (_isBreathing)
  LinearProgressIndicator(
    value: _elapsedSeconds / (_selectedMinutes * 60),
    backgroundColor: Colors.grey.shade200,
    valueColor: AlwaysStoppedAnimation(Colors.blue),
  ),
```

### Snippet 3: Countdown Timer
```dart
Timer? _countdownTimer;
int _remainingSeconds = 0;

void _startBreathing() {
  setState(() {
    _isBreathing = true;
    _remainingSeconds = _selectedMinutes * 60;
  });
  
  _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _stopBreathing();
        _onBreathingComplete();
      }
    });
  });
}

void _stopBreathing() {
  _countdownTimer?.cancel();
  setState(() {
    _isBreathing = false;
  });
}

// Display countdown:
Text(
  '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:'
  '${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
  style: TextStyle(fontSize: 24),
),
```

---

## 🎨 Visual Tweaks Quick Reference

```dart
// Make flower bigger
size: 300, // Was 260

// Change animation speed
breathDuration: Duration(seconds: 6), // Was 5

// Adjust spacing
SizedBox(height: 80), // Was 70

// Change button height
height: 64, // Was 56

// Modify pill padding
padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Was 20, 12

// Adjust border radius
borderRadius: BorderRadius.circular(30), // Was 25

// Change font size
fontSize: 20, // Was 18
```

---

## 🚀 Performance Optimization

### Lazy Load Widgets:
```dart
// Only build when visible
Visibility(
  visible: _isBreathing,
  child: BreathingFlowerAnimation(...),
  replacement: SizedBox(height: 260), // Placeholder
)
```

### Const Optimization:
```dart
// Mark as const wherever possible
const SizedBox(height: 40),
const Text('Breathing'),
const EdgeInsets.symmetric(horizontal: 24),
```

### Precache Images:
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Precache any images
  precacheImage(AssetImage('assets/flower_bg.png'), context);
}
```

---

## 📱 Responsive Design Helpers

```dart
// Adapt to screen size
double getFlowerSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 360) return 200; // Small phones
  if (width < 414) return 260; // Medium phones
  return 300; // Large phones/tablets
}

// Use:
BreathingFlowerAnimation(
  size: getFlowerSize(context),
  // ...
)
```

---

## ✅ Quick Checklist for Go-Live

- ✅ No compilation errors
- ✅ Tested on iOS simulator
- ✅ Tested on Android emulator
- ✅ Dark mode works
- ✅ Light mode works
- ✅ Animations smooth (60 FPS)
- ✅ No memory leaks (controllers disposed)
- ✅ Navigation works from all entry points
- ✅ Back button works correctly
- ✅ Orientation change handled
- ✅ Screenshots taken for store listing

---

**Ready to integrate! Pick any snippet and customize to your needs.** 🚀
