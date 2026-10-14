import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/custom_api_call.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../instance/locator.dart';
import '../models/auth_response_model.dart';

class AuthService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  static const String _tokenKey = 'loginToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';

  String get _baseUrl {
    final envUrl = dotenv.env['BACKEND_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    // Auto-resolve localhost for Android emulator vs iOS simulator
    if (Platform.isAndroid)
      return 'https://mineaibackend-production.up.railway.app';
    return 'https://mineaibackend-production.up.railway.app';
  }

  /// Sign In against /api/v1/auth/login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.makeApiRequest(
        method: 'POST',
        token: '',
        url: '$_baseUrl/auth/login',
        data: {'email': email.trim(), 'password': password.trim()},
      );

      final responseData = response.data as Map<String, dynamic>;
      final payload =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      // Parse with your existing AuthResponseModel
      final authModel = AuthResponseModel.fromJson(payload);

      // 1. EXTRACT AND SAVE THE USER ID
      final userId = authModel.user?.id;
      if (userId != null && userId.isNotEmpty) {
        await _secureStorage.writeSecureData(_userIdKey, userId);
      }

      // 2. Save Access Token
      if (authModel.accessToken != null && authModel.accessToken!.isNotEmpty) {
        await _secureStorage.writeSecureData(_tokenKey, authModel.accessToken!);
      }

      return authModel;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Login failed';
      throw Exception(errorMsg);
    }
  }

  /// Register against /api/v1/auth/register (conforms with backend Zod validation)
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 1. Sanitize username: replace forbidden characters (like dots) with underscores
      final sanitizedUsername = email
          .split('@')
          .first
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

      // 2. Resolve system timezone dynamically
      final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
      final timezone = tzInfo.identifier.isNotEmpty ? tzInfo.identifier : 'UTC';

      final payload = {
        'email': email.trim(),
        'password': password.trim(),
        'full_name': fullName.trim(),
        'username': sanitizedUsername,
        'dob': '2000-01-01', // Required ISO date format YYYY-MM-DD
        'gender':
            'prefer_not_to_say', // male | female | other | prefer_not_to_say
        'country_code': 'IN', // 2-character country code
        'timezone': timezone,
        'language': 'en',
      };

      final response = await _apiService.makeApiRequest(
        method: 'POST',
        token: '',
        url: '$_baseUrl/auth/register',
        data: payload,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Registration failed';
      throw Exception(errorMsg);
    }
  }

  /// Wipes token on user logout
  Future<void> clearAuthSession() async {
    await _secureStorage.deleteSecureData(_tokenKey);
    await _secureStorage.deleteSecureData(_refreshTokenKey);
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
  }

  /// Reads cached token for automatic login checks
  Future<String?> getSavedToken() async {
    return await _secureStorage.readSecureData(_tokenKey);
  }
}
