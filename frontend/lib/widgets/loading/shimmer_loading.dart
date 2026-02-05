import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class DashboardShimmerLoading extends StatelessWidget {
  const DashboardShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie Card Shimmer
          ShimmerLoading(
            width: double.infinity,
            height: 220,
            borderRadius: BorderRadius.circular(24),
          ),

          const SizedBox(height: 24),

          // Scan Button Shimmer
          ShimmerLoading(
            width: double.infinity,
            height: 56,
            borderRadius: BorderRadius.circular(16),
          ),

          const SizedBox(height: 32),

          // Meal Section Shimmer
          const SizedBox(
            width: 150,
            height: 24,
            child: ShimmerLoading(width: 150, height: 24),
          ),

          const SizedBox(height: 16),

          ...List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShimmerLoading(
                width: double.infinity,
                height: 70,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),

          const SizedBox(height: 32),

          // Weekly Chart Shimmer
          const SizedBox(
            width: 150,
            height: 24,
            child: ShimmerLoading(width: 150, height: 24),
          ),

          const SizedBox(height: 16),

          ShimmerLoading(
            width: double.infinity,
            height: 220,
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
    );
  }
}

// Meal Card Shimmer for individual meal sections
class MealCardShimmer extends StatelessWidget {
  const MealCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          title: Container(
            height: 16,
            width: 100,
            color: Colors.white,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              height: 14,
              width: 150,
              color: Colors.white,
            ),
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
