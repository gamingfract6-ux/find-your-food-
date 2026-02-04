//



import 'package:flutter/foundation.dart';

class AppConstants {
  // API Configuration
  // API Configuration
  static String get apiBaseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    return 'http://10.0.2.2:8000/api'; // Android Emulator
  }
  static const String apiVersion = '/v1';
  
  // Endpoints
  static const String authGoogleSignin = '/auth/google-signin';
  static const String authProfile = '/auth/profile';
  static const String authMe = '/auth/me';
  static const String foodAnalyze = '/food/analyze';
  static const String foodHistory = '/food/history';
  static const String foodFeedback = '/food/feedback';
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyUser = 'user';
  static const String keyThemeMode = 'theme_mode';
  
  // App Info
  static const String appName = 'Find Your Food';
  static const String appVersion = '1.0.0';
  
  // Limits
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const double confidenceThreshold = 0.85;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Daily Recommendations
  static const int dailyCalories = 2000;
  static const int dailyProtein = 50;
  static const int dailyCarbs = 275;
  static const int dailyFats = 78;
}
