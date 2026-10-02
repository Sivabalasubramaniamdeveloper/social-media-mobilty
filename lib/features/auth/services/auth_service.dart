import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../../../core/network/custom_api_call.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../instance/locator.dart';
import '../models/auth_response_model.dart';

class AuthService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  static const String _tokenKey = 'loginToken';

  String get _baseUrl =>
      dotenv.env['BACKEND_BASE_URL'] ?? 'http://10.0.2.2:3000/api/v1';

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
      final authModel = AuthResponseModel.fromJson(payload);

      // Persist access token securely
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
  }

  /// Reads cached token for automatic login checks
  Future<String?> getSavedToken() async {
    return await _secureStorage.readSecureData(_tokenKey);
  }
}
