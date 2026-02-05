//


import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final userName = auth.userName ?? 'User';
    final userEmail = auth.userEmail ?? 'user@example.com';
    final userPhoto = auth.userPhotoUrl;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Profile Picture
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          image: DecorationImage(
                            image: NetworkImage(
                              userPhoto ?? 'https://ui-avatars.com/api/?name=$userName&size=200&background=10B981&color=fff',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats
                    _buildStatsCards(),
                    
                    const SizedBox(height: 24),
                    
                    // Personal Info Section
                    _buildSectionHeader(context, 'Personal Information'),
                    const SizedBox(height: 12),
                    _buildInfoCard(context),
                    
                    const SizedBox(height: 24),
                    
                    // Goals Section
                    _buildSectionHeader(context, 'Fitness Goals'),
                    const SizedBox(height: 12),
                    _buildGoalsCard(context),
                    
                    const SizedBox(height: 24),
                    
                    // Preferences Section
                    _buildSectionHeader(context, 'Dietary Preferences'),
                    const SizedBox(height: 12),
                    _buildPreferencesCard(context),
                    
                    const SizedBox(height: 24),
                    
                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        child: const Text('Edit Profile'),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Weight', '72 kg', Icons.monitor_weight)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Height', '175 cm', Icons.height)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Age', '28 yrs', Icons.cake)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.person, 'Gender', 'Male'),
            const Divider(),
            _buildInfoRow(Icons.calendar_today, 'Age', '28 years'),
            const Divider(),
            _buildInfoRow(Icons.monitor_weight, 'Weight', '72 kg'),
            const Divider(),
            _buildInfoRow(Icons.height, 'Height', '175 cm'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.flag, 'Fitness Goal', 'Weight Loss'),
            const Divider(),
            _buildInfoRow(Icons.local_fire_department, 'Daily Calories', '2000 kcal'),
            const Divider(),
            _buildInfoRow(Icons.location_on, 'Region', 'India'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.restaurant, 'Diet Type', 'Vegetarian'),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Allergies',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('Nuts'),
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.error),
                ),
                Chip(
                  label: const Text('Dairy'),
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
