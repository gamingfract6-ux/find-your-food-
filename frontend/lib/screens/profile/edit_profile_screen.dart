//


import 'package:flutter/material.dart';
import '../../config/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'John Doe');
  final _ageController = TextEditingController(text: '28');
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '72');
  
  String _selectedGender = 'Male';
  String _selectedGoal = 'Weight Loss';
  String _selectedDiet = 'Vegetarian';
  String _selectedRegion = 'India';
  
  final List<String> _allergies = ['Nuts', 'Dairy'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://ui-avatars.com/api/?name=John+Doe&size=200&background=10B981&color=fff',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Name
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your name';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Gender
            _buildDropdown(
              label: 'Gender',
              icon: Icons.wc,
              value: _selectedGender,
              items: ['Male', 'Female', 'Other'],
              onChanged: (value) {
                setState(() => _selectedGender = value!);
              },
            ),

            const SizedBox(height: 16),

            // Age
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your age';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Height (cm)
            _buildTextField(
              controller: _heightController,
              label: 'Height (cm)',
              icon: Icons.height,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your height';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Weight (kg)
            _buildTextField(
              controller: _weightController,
              label: 'Weight (kg)',
              icon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your weight';
                return null;
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Fitness Goals',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            // Fitness Goal
            _buildDropdown(
              label: 'Fitness Goal',
              icon: Icons.flag,
              value: _selectedGoal,
              items: ['Weight Loss', 'Weight Gain', 'Muscle Building', 'Maintenance'],
              onChanged: (value) {
                setState(() => _selectedGoal = value!);
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Dietary Preferences',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            // Diet Type
            _buildDropdown(
              label: 'Diet Type',
              icon: Icons.restaurant,
              value: _selectedDiet,
              items: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Keto', 'Paleo'],
              onChanged: (value) {
                setState(() => _selectedDiet = value!);
              },
            ),

            const SizedBox(height: 16),

            // Region
            _buildDropdown(
              label: 'Region',
              icon: Icons.location_on,
              value: _selectedRegion,
              items: ['India', 'USA', 'UK', 'Other'],
              onChanged: (value) {
                setState(() => _selectedRegion = value!);
              },
            ),

            const SizedBox(height: 16),

            // Allergies
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.error),
                        SizedBox(width: 12),
                        Text(
                          'Allergies',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ..._allergies.map((allergy) => Chip(
                          label: Text(allergy),
                          onDeleted: () {
                            setState(() => _allergies.remove(allergy));
                          },
                          backgroundColor: AppColors.error.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(color: AppColors.error),
                        )),
                        ActionChip(
                          label: const Text('Add'),
                          onPressed: _showAddAllergyDialog,
                          avatar: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _showAddAllergyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Allergy'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter allergy name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _allergies.add(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Save to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }
}
