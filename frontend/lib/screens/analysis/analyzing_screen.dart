//


import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../services/api_service.dart';
import '../../models/food_analysis.dart';
import 'results_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final File imageFile;

  const AnalyzingScreen({super.key, required this.imageFile});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ApiService _apiService = ApiService();
  bool _hasError = false;


  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Start analysis
    _analyzeImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    try {
      final FoodAnalysis analysis = await _apiService.analyzeFood(widget.imageFile);
      
      if (!mounted) return;
      
      // Navigate to results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            imageFile: widget.imageFile,
            analysis: analysis,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Analysis Failed'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Food Not Detected',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'We couldn\'t identify the food in this image. Please try:\n\n• Better lighting\n• Clearer photo\n• Different angle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Preview
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: FileImage(widget.imageFile),
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
            ),
            
            const SizedBox(height: 40),
            
            // Loading Spinner
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Status Text
            const Text(
              'Analyzing Food...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            const Text(
              'Our AI is detecting ingredients\nand calculating nutrition',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
