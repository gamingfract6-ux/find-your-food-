//


class DetectedFood {
  final String name;
  final double confidence;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;
  final double sodium;
  final String portion;
  final double weightGrams;

  DetectedFood({
    required this.name,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.portion,
    required this.weightGrams,
  });

  factory DetectedFood.fromJson(Map<String, dynamic> json) {
    return DetectedFood(
      name: json['name'],
      confidence: json['confidence'].toDouble(),
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fats: json['fats'].toDouble(),
      fiber: json['fiber']?.toDouble() ?? 0.0,
      sugar: json['sugar']?.toDouble() ?? 0.0,
      sodium: json['sodium']?.toDouble() ?? 0.0,
      portion: json['portion'],
      weightGrams: json['weight_grams'].toDouble(),
    );
  }
}

class FoodAnalysis {
  final int id;
  final String imageUrl;
  final List<DetectedFood> detectedFoods;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final double totalFiber;
  final double totalSugar;
  final double totalSodium;
  final double confidenceScore;
  final String healthScore;
  final List<String> dietaryTags;
  final String aiInsights;
  final double analysisTime;
  final DateTime createdAt;

  FoodAnalysis({
    required this.id,
    required this.imageUrl,
    required this.detectedFoods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.totalFiber,
    required this.totalSugar,
    required this.totalSodium,
    required this.confidenceScore,
    required this.healthScore,
    required this.dietaryTags,
    required this.aiInsights,
    required this.analysisTime,
    required this.createdAt,
  });

  factory FoodAnalysis.fromJson(Map<String, dynamic> json) {
    return FoodAnalysis(
      id: json['id'],
      imageUrl: json['image_url'],
      detectedFoods: (json['detected_foods'] as List)
          .map((f) => DetectedFood.fromJson(f))
          .toList(),
      totalCalories: json['total_calories'].toDouble(),
      totalProtein: json['total_protein'].toDouble(),
      totalCarbs: json['total_carbs'].toDouble(),
      totalFats: json['total_fats'].toDouble(),
      totalFiber: json['total_fiber'].toDouble(),
      totalSugar: json['total_sugar'].toDouble(),
      totalSodium: json['total_sodium'].toDouble(),
      confidenceScore: json['confidence_score'].toDouble(),
      healthScore: json['health_score'],
      dietaryTags: List<String>.from(json['dietary_tags']),
      aiInsights: json['ai_insights'],
      analysisTime: json['analysis_time'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
