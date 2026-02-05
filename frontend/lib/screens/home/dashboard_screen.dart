// Dashboard Screen - Main home screen with daily tracking
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/meal_log.dart';
import '../../services/database_service.dart';
import '../../widgets/charts/weekly_calorie_chart.dart';
import '../../widgets/loading/shimmer_loading.dart';
import 'camera_screen.dart';
import '../coach/ai_coach_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  List<MealLog> _todayLogs = [];
  Map<String, double> _todayMacros = {};
  List<double> _weeklyCalories = [0, 0, 0, 0, 0, 0, 0]; // Mon-Sun
  bool _isLoading = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadTodayData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final today = DateTime.now();
      
      // Load today's data
      final logs = await DatabaseService.instance.getMealLogsByDate(today);
      final macros = await DatabaseService.instance.getTotalMacrosForDate(today);

      // Load weekly data (Mon-Sun)
      final weekStart = today.subtract(Duration(days: today.weekday - 1)); // Monday
      final weeklyData = <double>[];
      
      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        final dayCalories = await DatabaseService.instance.getTotalCaloriesForDate(day);
        weeklyData.add(dayCalories);
      }

      setState(() {
        _todayLogs = logs;
        _todayMacros = macros;
        _weeklyCalories = weeklyData;
        _isLoading = false;
      });
      
      // Animate content in
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  // Get meals by type from today's logs
  List<MealLog> _getMealsByType(String mealType) {
    return _todayLogs
        .where((log) => log.mealType.toLowerCase() == mealType.toLowerCase())
        .toList();
  }

  // Get total calories for meal type
  double _getCaloriesForMealType(String mealType) {
    final meals = _getMealsByType(mealType);
    return meals.fold(0.0, (sum, log) => sum + log.calories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTodayData,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Find Your Food',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.psychology),
                    tooltip: 'AI Nutrition Coach',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiCoachScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Content
              SliverList(
                delegate: SliverChildListDelegate([
                  _isLoading
                      ? const DashboardShimmerLoading()
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Daily Calories Card
                              _buildCalorieCard(context),

                              const SizedBox(height: 24),

                              // Scan New Food Button
                              _buildScanButton(context),

                              const SizedBox(height: 32),

                              // Today's Meals Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Today's Meals",
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    '${_todayLogs.length} logged',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildMealTimeSection(context, 'Breakfast'),
                              _buildMealTimeSection(context, 'Lunch'),
                              _buildMealTimeSection(context, 'Dinner'),
                              _buildMealTimeSection(context, 'Snacks'),

                              const SizedBox(height: 32),

                              // Weekly Progress
                              Text(
                                "Weekly Progress",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),

                              _buildWeeklyChart(context),
                            ],
                          ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieCard(BuildContext context) {
    final consumed = _todayMacros['calories'] ?? 0.0;
    final protein = _todayMacros['protein'] ?? 0.0;
    final carbs = _todayMacros['carbs'] ?? 0.0;
    final fats = _todayMacros['fats'] ?? 0.0;

    final percent = (consumed / AppConstants.dailyCalories).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Daily Calories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          CircularPercentIndicator(
            radius: 80,
            lineWidth: 12,
            percent: percent,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${consumed.toInt()}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'kcal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            progressColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            circularStrokeCap: CircularStrokeCap.round,
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientPill('Protein', '${protein.toInt()}g', AppColors.protein),
              _buildNutrientPill('Carbs', '${carbs.toInt()}g', AppColors.carbs),
              _buildNutrientPill('Fats', '${fats.toInt()}g', AppColors.fats),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Navigate and reload on return
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
          // Reload data when returning from camera
          _loadTodayData();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 24),
            SizedBox(width: 12),
            Text(
              'Scan Food',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTimeSection(BuildContext context, String mealTime) {
    final calories = _getCaloriesForMealType(mealTime);
    final meals = _getMealsByType(mealTime);
    final mealCount = meals.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: calories > 0
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.restaurant,
            color: AppColors.primary,
            size: calories > 0 ? 24 : 20,
          ),
        ),
        title: Text(
          '$mealTime ${MealLog.getMealEmoji(mealTime.toLowerCase())}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          calories > 0
              ? '${calories.toInt()} kcal • $mealCount item${mealCount != 1 ? 's' : ''}'
              : 'Not logged yet',
          style: TextStyle(
            color: calories > 0 ? AppColors.textDark : AppColors.textMedium,
          ),
        ),
        trailing: Icon(
          calories > 0 ? Icons.check_circle : Icons.add_circle_outline,
          color: calories > 0 ? Colors.green : AppColors.primary,
        ),
        onTap: () async {
          // Navigate to camera screen to add meal
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraScreen(),
            ),
          );
          // Reload data
          _loadTodayData();
        },
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    return WeeklyCalorieChart(
      weeklyCalories: _weeklyCalories,
      dailyGoal: AppConstants.dailyCalories,
    );
  }
}
