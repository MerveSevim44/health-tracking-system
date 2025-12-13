# 🏥 MINOA - Health Tracking System

A modern, beautiful Flutter application for tracking your health journey with AI-powered insights.

## ✨ Features

- 🎭 **Mood Tracking**: Monitor your emotional well-being with AI insights
- 💧 **Hydration Goals**: Stay healthy by tracking your daily water intake
- 💊 **Medication Reminders**: Never miss a dose with smart notifications
- 🧠 **AI Coach**: Get personalized health recommendations
- 📊 **Beautiful Analytics**: Visualize your health data with stunning charts
- 🎨 **Modern UI**: Fresh, glassmorphic design with smooth animations

## 🎨 Recent Design Updates

The app features a completely redesigned authentication flow with:
- **Dark modern theme** with gradient accents
- **Glassmorphism effects** for a contemporary look
- **Smooth animations** and page transitions
- **Interactive landing page** with multiple sections
- **Accessibility-focused** design patterns

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account (for backend)

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd health-tracking-system
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## 🔥 Development Mode (Hot Reload)

Flutter has built-in hot reload for instant updates! See [DEV_MODE_GUIDE.md](DEV_MODE_GUIDE.md) for detailed instructions.

### Quick Start
```bash
# Run the app in dev mode
flutter run

# Then press 'r' to hot reload changes instantly
# Press 'R' to hot restart (full restart)
# Press 'q' to quit
```

### Hot Reload Benefits
- ⚡ See UI changes in **less than 1 second**
- 🔄 Preserves app state during reload
- 🎨 Perfect for UI/UX iterations

## 📱 Running on Different Platforms

```bash
# Android
flutter run -d android

# iOS (Mac only)
flutter run -d ios

# Web
flutter run -d chrome

# All devices
flutter run -d all
```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # All app screens
│   ├── landing_page.dart     # Modern landing page with sections
│   ├── login_screen.dart     # Login with glassmorphism
│   ├── register_screen.dart  # Sign up screen
│   ├── home_screen.dart      # Main dashboard
│   └── ...
├── models/                   # Data models
├── services/                 # Business logic & APIs
├── widgets/                  # Reusable components
├── theme/                    # App theming
└── utils/                    # Utilities & helpers
```

## 🎨 Design Philosophy

The app uses a modern design language with:
- **Deep purple & cyan gradients** for depth
- **Dark theme** for reduced eye strain
- **Glassmorphism** for contemporary feel
- **Smooth animations** for delightful UX
- **Accessibility** as a priority

## 🔧 Technologies Used

- **Flutter** - Cross-platform framework
- **Firebase Auth** - User authentication
- **Firebase Database** - Real-time data storage
- **Provider** - State management
- **FL Chart** - Beautiful charts & graphs

## 📝 Key Screens

### Landing Page
- Multiple interactive sections
- Swipeable pages with smooth transitions
- Feature showcase with auto-rotation
- Modern glassmorphic design

### Login/Register
- Glassmorphic text fields
- Gradient buttons with shadows
- Animated backgrounds
- Password visibility toggle
- Form validation

### Home Dashboard
- Quick stats overview
- Activity tracking
- Mood check-in
- Water & medication tracking

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- The health & wellness community for inspiration

---

**Built with ❤️ using Flutter**
