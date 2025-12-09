# 🎨 Pastel Mood Tracking UI Kit - Complete Documentation

## 📱 Overview

A complete Flutter UI kit designed with soft pastel colors, cute blob characters, and minimalistic layouts inspired by modern mood-tracking apps like Calm, Moodnotes, and Stoic.

## 🎨 Design System

### Color Palette

```dart
// Pastel Backgrounds
pastelYellow  = #FFF9E6
pastelMint    = #E8F5E3
pastelLavender = #F3EFFF
pastelPink    = #FFE8F0
pastelPeach   = #FFECDB
pastelBlue    = #E3F2FD

// Mood Colors
moodHappy    = #FFD166  (Yellow/Orange)
moodCalm     = #06D6A0  (Mint Green)
moodSad      = #118AB2  (Blue)
moodAnxious  = #EF476F  (Pink/Red)
moodAngry    = #FF6B6B  (Red)
moodNeutral  = #B8B8B8  (Gray)

// Text Colors
textDark     = #2D3436
textMedium   = #636E72
textLight    = #B2BEC3
```

### Typography

- **Font**: Inter or SF Pro Display
- **Weights**: 300 (light), 400 (regular), 500 (medium), 600 (semibold)
- **Display Large**: 32px, weight 300
- **Display Medium**: 28px, weight 400
- **Headline Large**: 24px, weight 500
- **Headline Medium**: 20px, weight 500
- **Body Large**: 16px, weight 400
- **Body Medium**: 14px, weight 400
- **Body Small**: 12px, weight 400

### Border Radius

- Cards: 20-24px
- Buttons: 30px (fully rounded)
- Small elements: 12-16px

## 🧩 Reusable Components

### 1. MoodBlob Widget

Cute animated blob characters with different expressions.

```dart
MoodBlob(
  size: 120,
  color: AppColors.moodHappy,
  expression: MoodExpression.happy,
  animated: true,
)
```

**Expressions:**
- `happy` - Smiling eyes and curved smile
- `calm` - Closed peaceful eyes with small smile
- `sad` - Round eyes with downturned mouth
- `anxious` - Wide eyes with small O mouth
- `angry` - Angry eyebrows and straight mouth
- `neutral` - Round eyes with straight mouth

### 2. PastelCard

Basic card component with soft shadows.

```dart
PastelCard(
  backgroundColor: AppColors.cardBackground,
  padding: EdgeInsets.all(20),
  borderRadius: 24,
  child: YourContent(),
)
```

### 3. GradientBackground

Smooth gradient backgrounds for screens.

```dart
GradientBackground(
  colors: [
    AppColors.gradientYellowStart,
    AppColors.gradientYellowEnd,
  ],
  child: YourScreen(),
)
```

### 4. MoodOptionButton

Mood selection buttons with rounded design.

```dart
MoodOptionButton(
  label: 'Good',
  isSelected: true,
  onTap: () {},
)
```

### 5. WeeklyMoodCircle

Circular mood indicators for weekly view.

```dart
WeeklyMoodCircle(
  day: 'M',
  moodScore: 8,  // 1-10
  isSelected: true,
)
```

### 6. ExerciseCard

Cards for breathing exercises and activities.

```dart
ExerciseCard(
  title: 'Relieve stress',
  subtitle: 'Breathing practice',
  duration: '15 min',
  backgroundColor: AppColors.pastelPink,
  illustration: MoodBlob(...),
  onTap: () {},
)
```

### 7. MoodTile

Daily mood log tiles.

```dart
MoodTile(
  day: 'Monday',
  color: AppColors.moodHappy,
  isToday: true,
)
```

### 8. StatsCard

Statistics display cards.

```dart
StatsCard(
  title: 'Your Mood\nScore',
  value: '7.5',
  backgroundColor: AppColors.pastelYellow,
  icon: YourIcon(),
)
```

## 📱 Complete Screens

### 1. Mood Selection Screen

**File:** `lib/screens/mood_selection_screen.dart`

Features:
- Gradient yellow/orange background
- Large animated blob in center
- Title: "How are you really feeling today?"
- Wave animation for mood intensity
- Mood options: Great, Good, Neutral, Bad, Awful

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MoodSelectionScreen(),
  ),
);
```

### 2. Weekly Dashboard Screen

**File:** `lib/screens/weekly_dashboard_screen.dart`

Features:
- Mint green gradient background
- Greeting: "Dear Alice, good morning"
- Time filter tabs (Month/Week/Day)
- Weekly mood circles (7 days)
- Mood trend line chart (fl_chart)
- Stress level visualization
- Exercise cards with blobs

**Charts:**
- Line chart for mood trends
- Bar chart for stress levels

### 3. Insights/Analytics Screen

**File:** `lib/screens/insights_screen.dart`

Features:
- Lavender gradient background
- Alert section: "Your condition has worsened recently"
- Purple mood trend line chart
- Test cards with blob illustrations:
  - The balance of life today
  - Your source of negativity
  - Triggers of bad moods

### 4. Daily Mood Home Screen

**File:** `lib/screens/daily_mood_home_screen.dart`

Features:
- Profile header with avatar
- Greeting: "Hello Ridgy! 👋"
- Quick action chips (Mood, Meditation, Music)
- Daily mood log (5-day tiles)
- Today's task section
- Mood score card
- Streak information
- Sleep summary with bar chart
- My Mood breakdown

### 5. Pastel Home Navigation

**File:** `lib/screens/pastel_home_navigation.dart`

Main navigation container with:
- Bottom navigation bar (4 icons)
- Floating action button (Add mood)
- Screen switching between:
  - Daily Mood Home
  - Weekly Dashboard
  - Insights
  - Profile

## 📊 Charts Integration (fl_chart)

### Line Chart Example

```dart
LineChart(
  LineChartData(
    gridData: FlGridData(show: false),
    titlesData: FlTitlesData(show: false),
    borderData: FlBorderData(show: false),
    lineBarsData: [
      LineChartBarData(
        spots: [
          FlSpot(0, 3),
          FlSpot(1, 4),
          FlSpot(2, 2),
          // ... more data points
        ],
        isCurved: true,
        color: AppColors.moodCalm,
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: AppColors.moodCalm.withValues(alpha: 0.2),
        ),
      ),
    ],
  ),
)
```

### Bar Chart Example

```dart
BarChart(
  BarChartData(
    gridData: FlGridData(show: false),
    titlesData: FlTitlesData(show: false),
    borderData: FlBorderData(show: false),
    barGroups: [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: 5,
            color: AppColors.pastelPink,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      ),
      // ... more bars
    ],
  ),
)
```

## 🗂️ Project Structure

```
lib/
├── theme/
│   └── app_theme.dart              # Pastel color palette & theme
├── widgets/
│   ├── mood_blob.dart              # Blob character widget
│   ├── pastel_components.dart      # Reusable UI components
│   └── theme.dart                  # Old theme (can be removed)
├── screens/
│   ├── mood_selection_screen.dart  # Mood selection UI
│   ├── weekly_dashboard_screen.dart # Weekly mood dashboard
│   ├── insights_screen.dart        # Analytics & insights
│   ├── daily_mood_home_screen.dart # Daily home screen
│   ├── pastel_home_navigation.dart # Main navigation
│   ├── first_screen.dart           # Welcome screen
│   └── ... (other screens)
├── models/
│   └── mood_model.dart             # Mood state management
└── main.dart                       # App entry point
```

## 🚀 Getting Started

### 1. Install Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  fl_chart: ^0.69.0
  provider: ^6.1.5
```

Run:
```bash
flutter pub get
```

### 2. Import Theme

```dart
import 'package:health_care/theme/app_theme.dart';

MaterialApp(
  theme: pastelAppTheme,
  home: YourHomeScreen(),
)
```

### 3. Use Components

```dart
import 'package:health_care/widgets/mood_blob.dart';
import 'package:health_care/widgets/pastel_components.dart';

// In your widget
PastelCard(
  child: MoodBlob(
    size: 100,
    color: AppColors.moodHappy,
    expression: MoodExpression.happy,
  ),
)
```

## 🎯 Navigation Flow

```
FirstScreen (Welcome)
  └─> PastelHomeNavigation
      ├─> DailyMoodHomeScreen (Tab 1)
      ├─> WeeklyDashboardScreen (Tab 2)
      ├─> InsightsScreen (Tab 3)
      └─> ProfilePlaceholder (Tab 4)
      
FloatingActionButton → MoodSelectionScreen
```

## ✨ Key Features

1. **Soft Pastel Aesthetics**: Calming colors perfect for wellness apps
2. **Cute Blob Characters**: 6 different expressions with smooth animations
3. **Smooth Animations**: Scale, bounce, and fade transitions
4. **Data Visualization**: Beautiful line and bar charts using fl_chart
5. **Minimalistic Design**: Clean layouts with ample white space
6. **Reusable Components**: Easy to customize and extend
7. **Responsive Layout**: Works on different screen sizes
8. **iOS-style Navigation**: Bottom bar with minimal icons

## 🎨 Customization

### Change Colors

Edit `lib/theme/app_theme.dart`:
```dart
class AppColors {
  static const Color pastelYellow = Color(0xFFYOURCOLOR);
  // ... modify other colors
}
```

### Add New Blob Expression

Edit `lib/widgets/mood_blob.dart`:
```dart
enum MoodExpression {
  happy,
  calm,
  // ... add your new expression
  excited,
}

// Then implement in BlobPainter._drawFace()
```

### Customize Charts

Modify chart data and styling in respective screen files:
- `weekly_dashboard_screen.dart`
- `insights_screen.dart`
- `daily_mood_home_screen.dart`

## 📦 Dependencies

- **flutter**: SDK
- **fl_chart**: ^0.69.0 - Beautiful charts
- **provider**: ^6.1.5 - State management
- **firebase_core**: ^3.15.2 - Firebase integration
- **firebase_auth**: ^5.3.4 - Authentication
- **firebase_database**: ^11.3.10 - Real-time database

## 🔄 Running the App

```bash
# Get dependencies
flutter pub get

# Run on web
flutter run -d edge

# Run on mobile
flutter run

# Hot reload
r (in terminal while app is running)
```

## 📝 Notes

- All screens use Material 3 design
- Blob animations use CustomPainter for performance
- Charts are fully customizable via fl_chart
- Theme supports both light mode (dark mode can be added)
- All components follow consistent 20-24px border radius
- Soft shadows use alpha: 0.1 for subtle elevation

## 🎉 What's Included

✅ Complete pastel color theme
✅ 8+ reusable components
✅ 5 fully designed screens
✅ Blob character widget with 6 expressions
✅ Line and bar chart implementations
✅ Bottom navigation setup
✅ Gradient backgrounds
✅ Smooth animations
✅ Clean, production-ready code

---

**Created with ❤️ for Flutter developers building wellness and mood-tracking apps**
