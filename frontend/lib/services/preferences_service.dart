import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyDailyCalorieGoal = 'daily_calorie_goal';
  static const String _keyProteinGoal = 'protein_goal';
  static const String _keyCarbsGoal = 'carbs_goal';
  static const String _keyFatsGoal = 'fats_goal';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyNotifications = 'notifications';
  static const String _keyMetricUnits = 'metric_units';

  // Save daily calorie goal
  static Future<void> setDailyCalorieGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDailyCalorieGoal, goal);
  }

  // Get daily calorie goal (default: 2000)
  static Future<double> getDailyCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyDailyCalorieGoal) ?? 2000.0;
  }

  // Save macro goals
  static Future<void> setMacroGoals({
    double? protein,
    double? carbs,
    double? fats,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (protein != null) await prefs.setDouble(_keyProteinGoal, protein);
    if (carbs != null) await prefs.setDouble(_keyCarbsGoal, carbs);
    if (fats != null) await prefs.setDouble(_keyFatsGoal, fats);
  }

  // Get macro goals
  static Future<Map<String, double>> getMacroGoals() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'protein': prefs.getDouble(_keyProteinGoal) ?? 150.0,
      'carbs': prefs.getDouble(_keyCarbsGoal) ?? 200.0,
      'fats': prefs.getDouble(_keyFatsGoal) ?? 65.0,
    };
  }

  // Dark mode preference
  static Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, enabled);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  // Notifications preference
  static Future<void> setNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }

  static Future<bool> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifications) ?? true;
  }

  // Units preference (true = metric, false = imperial)
  static Future<void> setMetricUnits(bool metric) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMetricUnits, metric);
  }

  static Future<bool> getMetricUnits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMetricUnits) ?? true;
  }

  // Clear all preferences
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
