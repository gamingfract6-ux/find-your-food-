import 'food_analysis.dart';

class MealLog {
  final int? id;
  final String userId;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snacks'
  final DateTime timestamp;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;
  final double sodium;
  final String portion;
  final int weightGrams;
  final String? imageUrl;
  final String? notes;

  MealLog({
    this.id,
    required this.userId,
    required this.mealType,
    required this.timestamp,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.portion,
    required this.weightGrams,
    this.imageUrl,
    this.notes,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'mealType': mealType,
      'timestamp': timestamp.toIso8601String(),
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'portion': portion,
      'weightGrams': weightGrams,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }

  // Create from Map (database result)
  factory MealLog.fromMap(Map<String, dynamic> map) {
    return MealLog(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      mealType: map['mealType'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      foodName: map['foodName'] as String,
      calories: map['calories'] as double,
      protein: map['protein'] as double,
      carbs: map['carbs'] as double,
      fats: map['fats'] as double,
      fiber: map['fiber'] as double,
      sugar: map['sugar'] as double,
      sodium: map['sodium'] as double,
      portion: map['portion'] as String,
      weightGrams: map['weightGrams'] as int,
      imageUrl: map['imageUrl'] as String?,
      notes: map['notes'] as String?,
    );
  }

  // Create from FoodAnalysis
  factory MealLog.fromFoodAnalysis({
    required FoodAnalysis analysis,
    required String mealType,
    String userId = 'default_user',
    String? notes,
  }) {
    final firstFood = analysis.foods.isNotEmpty ? analysis.foods.first : null;
    
    return MealLog(
      userId: userId,
      mealType: mealType,
      timestamp: DateTime.now(),
      foodName: firstFood?.name ?? 'Unknown Food',
      calories: firstFood?.calories ?? 0,
      protein: firstFood?.protein ?? 0,
      carbs: firstFood?.carbs ?? 0,
      fats: firstFood?.fats ?? 0,
      fiber: firstFood?.fiber ?? 0,
      sugar: firstFood?.sugar ?? 0,
      sodium: firstFood?.sodium ?? 0,
      portion: firstFood?.portion ?? '1 serving',
      weightGrams: firstFood?.weightGrams ?? 100,
      imageUrl: analysis.imageUrl,
      notes: notes,
    );
  }

  // Get meal type from time of day
  static String getMealTypeFromTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 11) return 'breakfast';
    if (hour >= 11 && hour < 15) return 'lunch';
    if (hour >= 15 && hour < 19) return 'snacks';
    return 'dinner';
  }

  // Get emoji for meal type
  static String getMealEmoji(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '🌞';
      case 'dinner':
        return '🌙';
      case 'snacks':
        return '🍿';
      default:
        return '🍽️';
    }
  }
}
