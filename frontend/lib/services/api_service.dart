// API Service for backend communication
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../config/constants.dart';
import '../models/user.dart';
import '../models/food_analysis.dart';

class ApiService {
  late final Dio _dio;
  String? _accessToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // print('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  // Authentication
  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    try {
      final response = await _dio.post(
        AppConstants.authGoogleSignin,
        data: {'id_token': idToken},
      );
      _accessToken = response.data['access_token'];
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get(AppConstants.authMe);
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put(
        AppConstants.authProfile,
        data: profileData,
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Food Analysis
  Future<FoodAnalysis> analyzeFood(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post(
        AppConstants.foodAnalyze,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return FoodAnalysis.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<FoodAnalysis> getAnalysis(int scanId) async {
    try {
      final response = await _dio.get('/food/analysis/$scanId');
      return FoodAnalysis.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getHistory() async {
    try {
      final response = await _dio.get(AppConstants.foodHistory);
      return response.data as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitFeedback({
    required int scanId,
    required bool isAccurate,
    String? correctFoodName,
    String? comments,
  }) async {
    try {
      await _dio.post(
        AppConstants.foodFeedback,
        data: {
          'scan_id': scanId,
          'is_accurate': isAccurate,
          'correct_food_name': correctFoodName,
          'comments': comments,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
