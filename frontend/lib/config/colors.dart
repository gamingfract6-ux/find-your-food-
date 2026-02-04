// Premium color palette for CalorAI
// Emerald green to electric blue gradient scheme
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Gradient)
  static const primary = Color(0xFF10B981); // Emerald Green
  static const secondary = Color(0xFF3B82F6); // Electric Blue
  static const accent = Color(0xFF8B5CF6); // Purple accent
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
  );
  
  // Background
  static const backgroundLight = Color(0xFFF8FAFC);
  static const backgroundDark = Color(0xFF0F172A);
  
  // Card & Surface
  static const surfaceLight = Colors.white;
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF1E293B);
  
  // Text Colors
  static const textDark = Color(0xFF1E293B);
  static const textMedium = Color(0xFF64748B);
  static const textLight = Color(0xFFF8FAFC);
  static const textMediumDark = Color(0xFFCBD5E1);
  
  // Border
  static const border = Color(0xFFE2E8F0);
  static const borderDark = Color(0xFF334155);
  
  // Status Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Health Score Colors
  static const healthAPlus = Color(0xFF10B981); // Green
  static const healthA = Color(0xFF84CC16); // Lime
  static const healthB = Color(0xFFFBAF02); // Yellow
  static const healthC = Color(0xFFF59E0B); // Orange
  static const healthD = Color(0xFFEF4444); // Red
  
  // Nutrition Colors
  static const protein = Color(0xFFEC4899); // Pink
  static const carbs = Color(0xFFF59E0B); // Orange
  static const fats = Color(0xFF8B5CF6); // Purple
  static const fiber = Color(0xFF10B981); // Green
  static const sugar = Color(0xFFEF4444); // Red
  static const sodium = Color(0xFF3B82F6); // Blue
  
  // Glass effect
  static Color glass(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.1);
  }
}
