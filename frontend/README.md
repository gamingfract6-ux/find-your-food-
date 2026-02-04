# CalorAI - Frontend

Premium AI-powered food calorie tracking mobile app built with Flutter.

## Features

- 🎨 **Premium UI/UX**: Emerald-blue gradient color scheme with glassmorphism
- 📸 **Camera Integration**: Capture or upload food images
- 🤖 **AI Analysis**: Real-time food detection and nutrition calculation
- 📊 **Dashboard**: Daily calorie tracking with circular progress indicators
- 🎯 **Health Scoring**: A+ to D rating system
- 💡 **AI Insights**: Personalized nutrition recommendations
- 🌓 **Dark Mode**: Automatic light/dark theme switching
- 🔐 **Google Sign-In**: Secure authentication

## Setup Instructions

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extension
- Android emulator or iOS simulator

### Installation

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure backend URL**
   Edit `lib/config/constants.dart`:
   ```dart
   static const String apiBaseUrl = 'http://YOUR_IP:8000/api';
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS (macOS only)
   flutter run -d ios

   # For web (testing)
   flutter run -d chrome
   ```

## Project Structure

```
frontend/
├── lib/
│   ├── main.dart              # App entry point
│   ├── config/
│   │   ├── theme.dart         # App theme
│   │   ├── colors.dart        # Color palette
│   │   └── constants.dart     # API endpoints
│   ├── models/                # Data models
│   │   ├── user.dart
│   │   └── food_analysis.dart
│   ├── services/              # API & business logic
│   │   └── api_service.dart
│   ├── screens/               # UI screens
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── home/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── camera_screen.dart
│   │   └── analysis/
│   │       ├── analyzing_screen.dart
│   │       └── results_screen.dart
│   └── widgets/               # Reusable components
├── assets/
├── android/
├── ios/
└── pubspec.yaml
```

## Key Dependencies

- `dio`: HTTP client for API calls
- `google_fonts`: Inter font family
- `image_picker`: Camera & gallery access
- `percent_indicator`: Circular progress indicators
- `google_sign_in`: Google authentication

## Design System

### Colors
- **Primary**: Emerald Green (#10B981)
- **Secondary**: Electric Blue (#3B82F6)
- **Accent**: Purple (#8B5CF6)

### Typography
- **Font Family**: Inter (Google Fonts)
- **Weights**: Regular (400), Medium (500), Semibold (600), Bold (700)

### Components
- **Card Border Radius**: 20px
-**Button Border Radius**: 16px
- **Elevation**: Subtle shadows with 0 elevation for flat design

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Build for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle
```

### iOS (macOS only)
```bash
flutter build ios --release
```

## Troubleshooting

### Camera not working on emulator
Use a physical device for camera testing, or use the gallery option.

### Network error
Ensure backend is running and update `apiBaseUrl` in constants.dart with your machine's IP address.

### Dependency conflicts
```bash
flutter clean
flutter pub get
```

## Demo Account
For testing without Google auth, the app uses a demo user when backend is unavailable.

## License
Proprietary - CalorAI © 2026
