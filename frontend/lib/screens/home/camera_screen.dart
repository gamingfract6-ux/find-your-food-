//


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/colors.dart';
import '../analysis/analyzing_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Scan Food'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera Icon
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Instructions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Position the food in frame\nand tap capture',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery Button
                _buildCircleButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                
                // Capture Button
                _buildCircleButton(
                  icon: Icons.camera,
                  label: 'Capture',
                  onTap: () => _pickImage(ImageSource.camera),
                  isPrimary: true,
                  size: 80,
                ),
                
                // Flash Button
                _buildCircleButton(
                  icon: Icons.flash_off,
                  label: 'Flash',
                  onTap: () {
                    // Toggle flash
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary ? AppColors.primary : Colors.white.withValues(alpha: 0.2),
              border: !isPrimary
                  ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? 36 : 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        
        if (!mounted) return;
        
        // Navigate to analyzing screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalyzingScreen(imageFile: imageFile),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
