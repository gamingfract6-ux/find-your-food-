//


import'dart:io';
import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../models/food_analysis.dart';
import '../../models/meal_log.dart';
import '../../services/database_service.dart';
import '../../utils/string_extensions.dart';

class ResultsScreen extends StatelessWidget {
  final File imageFile;
  final FoodAnalysis analysis;

  const ResultsScreen({
    super.key,
    required this.imageFile,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Detected Foods
            _buildImageCard(context),
            
            const SizedBox(height: 24),
            
            // Total Calories Card
            _buildCaloriesCard(context),
            
            const SizedBox(height: 24),
            
            // Macronutrients
            _buildMacronutrientsCard(context),
            
            const SizedBox(height: 24),
            
            // Micronutrients
            _buildMicronutrientsCard(context),
            
            const SizedBox(height: 24),
            
            // Health Score & Tags
            _buildHealthScoreCard(context),
            
            const SizedBox(height: 24),
            
            // AI Insights
            _buildInsightsCard(context),
            
            const SizedBox(height: 24),
            
            // Detected Foods Details
            _buildDetectedFoodsCard(context),
            
            const SizedBox(height: 24),
            
            // Save to Meal Button - Premium UX
            _buildSaveMealButton(context),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _showMealTypeSelector(BuildContext context) async {
    // Auto-detect meal type based on current time
    final suggestedMealType = MealLog.getMealTypeFromTime(DateTime.now());
    
    final mealTypes = [
      {'type': 'breakfast', 'label': 'Breakfast', 'icon': '🌅', 'time': '5am-11am'},
      {'type': 'lunch', 'label': 'Lunch', 'icon': '🌞', 'time': '11am-3pm'},
      {'type': 'snacks', 'label': 'Snacks', 'icon': '🍿', 'time': '3pm-7pm'},
      {'type': 'dinner', 'label': 'Dinner', 'icon': '🌙', 'time': '7pm-5am'},
    ];

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Save to Meal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose which meal to log this food to',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Meal Type Options
              ...mealTypes.map((meal) {
                final isSuggested = meal['type'] == suggestedMealType;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        await _saveMealLog(context, meal['type'] as String);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSuggested ? AppColors.primaryGradient : null,
                          color: isSuggested ? null : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(16),
                          border: isSuggested ? null : Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSuggested
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                meal['icon'] as String,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Label
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        meal['label'] as String,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: isSuggested ? Colors.white : AppColors.textDark,
                                        ),
                                      ),
                                      if (isSuggested) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Suggested',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    meal['time'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSuggested
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Arrow
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isSuggested ? Colors.white : AppColors.textMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveMealLog(BuildContext context, String mealType) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Saving meal...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );

      // Save to database
      final mealLog = MealLog.fromFoodAnalysis(
        analysis: analysis,
        mealType: mealType,
      );
      
      await DatabaseService.instance.insertMealLog(mealLog);

      if (!context.mounted) return;

      // Show success
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('✨ Saved to ${mealType.capitalize()}!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back to dashboard
      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return;
      
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving meal: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Widget _buildSaveMealButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMealTypeSelector(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_add, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Save to Meal Log',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: FileImage(imageFile),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              analysis.detectedFoods.map((f) => f.name).join(', '),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(analysis.confidenceScore * 100).toInt()}% confidence',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Calories',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${analysis.totalCalories.toInt()}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'kcal',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          _buildHealthScoreBadge(),
        ],
      ),
    );
  }

  Widget _buildHealthScoreBadge() {
    Color scoreColor;
    switch (analysis.healthScore) {
      case 'A+':
      case 'A':
        scoreColor = AppColors.healthAPlus;
        break;
      case 'B':
        scoreColor = AppColors.healthB;
        break;
      case 'C':
        scoreColor = AppColors.healthC;
        break;
      default:
        scoreColor = AppColors.healthD;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Health',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
          Text(
            analysis.healthScore,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildNutrientRow('Protein', analysis.totalProtein, 'g', AppColors.protein),
            _buildNutrientRow('Carbs', analysis.totalCarbs, 'g', AppColors.carbs),
            _buildNutrientRow('Fats', analysis.totalFats, 'g', AppColors.fats),
          ],
        ),
      ),
    );
  }

  Widget _buildMicronutrientsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Micronutrients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildNutrientRow('Fiber', analysis.totalFiber, 'g', AppColors.fiber),
            _buildNutrientRow('Sugar', analysis.totalSugar, 'g', AppColors.sugar),
            _buildNutrientRow('Sodium', analysis.totalSodium, 'mg', AppColors.sodium),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String name, double value, String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dietary Tags',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analysis.dietaryTags.map((tag) {
                return Chip(
                  label: Text(tag.replaceAll('_', ' ')),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb, color: AppColors.info),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI Insights',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              analysis.aiInsights,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedFoodsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detected Foods',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...analysis.detectedFoods.map((food) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food.portion,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${food.calories.toInt()} kcal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
