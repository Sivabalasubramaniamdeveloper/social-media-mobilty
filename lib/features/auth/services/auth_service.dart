import 'package:dio/dio.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:mineai/config/env/env_config.dart';
import 'package:mineai/config/firebase/push_notification.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/user_helper.dart';
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

  /// Sign In against /api/v1/auth/login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      String? fcmToken;
      try {
        fcmToken = await PushNotificationService.instance.refreshFcmToken();
      } catch (_) {}

      final response = await _apiService.makeApiRequest(
        method: 'POST',
        token: '',
        url: '${UserHelper.baseUrl}/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
        },
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

      // 3. Save Refresh Token for silent auto-refresh
      if (authModel.refreshToken != null &&
          authModel.refreshToken!.isNotEmpty) {
        await _secureStorage.writeSecureData(
          _refreshTokenKey,
          authModel.refreshToken!,
        );
      }

      // Supabase setSession expects a refresh token, not the access token.
      if (authModel.refreshToken != null &&
          authModel.refreshToken!.isNotEmpty) {
        try {
          await Supabase.instance.client.auth.setSession(
            authModel.refreshToken!,
          );
        } catch (_) {}
      }

      // Automatically sync the device's FCM push token to user profile
      try {
        await PushNotificationService.instance.refreshFcmToken();
      } catch (_) {}

      return authModel;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['code'] == 'EMAIL_NOT_CONFIRMED'
          ? AppStrings.emailNotVerified
          : AppStrings.loginFailed;
      throw Exception(errorMsg);
    }
  }

  /// Creates a Supabase account and requests confirmation before login is available.
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final sanitizedUsername = email
          .split('@')
          .first
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
      final timezone = tzInfo.identifier.isNotEmpty ? tzInfo.identifier : 'UTC';
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: EnvConfig.emailConfirmationRedirectUri,
        data: {
          'full_name': fullName.trim(),
          'username': sanitizedUsername,
          'dob': '2000-01-01',
          'gender': 'prefer_not_to_say',
          'country_code': 'IN',
          'timezone': timezone,
          'language': 'en',
        },
      );
      final user = response.user;
      if (user == null) throw Exception(AppStrings.registrationFailed);
      if (user.identities?.isEmpty ?? false) {
        throw Exception(AppStrings.emailAlreadyRegistered);
      }
      if (response.session != null || user.emailConfirmedAt != null) {
        await Supabase.instance.client.auth.signOut();
        throw Exception(AppStrings.emailVerificationDisabled);
      }
      return {
        'user': {'id': user.id, 'email': user.email},
      };
    } on AuthException catch (error) {
      final message = error.message.toLowerCase();
      if (message.contains('already registered') ||
          message.contains('already exists')) {
        throw Exception(AppStrings.emailAlreadyRegistered);
      }
      if (message.contains('password')) {
        throw Exception(AppStrings.passwordTooShort);
      }
      throw Exception(AppStrings.registrationFailed);
    }
  }

  /// Sends a new Supabase signup confirmation message for the provided email.
  Future<void> resendSignupConfirmation(String email) async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
    } on AuthException {
      throw Exception(AppStrings.resendVerificationFailed);
    }
  }

  /// Requests a Supabase recovery email without revealing whether the address exists.
  Future<void> requestPasswordReset(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: EnvConfig.passwordRecoveryRedirectUri,
      );
    } on AuthException {
      throw Exception(AppStrings.passwordResetRequestFailed);
    }
  }

  /// Updates the password using the recovery session opened by a Supabase link.
  Future<void> updatePassword(String password) async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      await clearAuthSession();
    } on AuthException {
      throw Exception(AppStrings.passwordUpdateFailed);
    }
  }

  /// Rotates the saved refresh token through the backend and stores the new token pair.
  Future<String?> refreshAccessToken() async {
    final refreshToken = await _secureStorage.readSecureData(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      // Use a clean Dio instance to avoid recursive 401 interceptor loops
      final plainDio = Dio();
      final response = await plainDio.post(
        '${UserHelper.baseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _secureStorage.writeSecureData(_tokenKey, newAccessToken);

          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _secureStorage.writeSecureData(
              _refreshTokenKey,
              newRefreshToken,
            );
          }

          // Handshake new token to Supabase client
          try {
            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await Supabase.instance.client.auth.setSession(newRefreshToken);
            }
          } catch (_) {}

          return newAccessToken;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Wipes token on user logout
  Future<void> clearAuthSession() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_devices')
            .update({'is_active': false, 'push_token': null})
            .eq('user_id', user.id);
      }
    } catch (_) {}
    await _secureStorage.deleteSecureData(_tokenKey);
    await _secureStorage.deleteSecureData(_refreshTokenKey);
    await _secureStorage.deleteSecureData(_userIdKey);
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
  }

  /// Reads cached token for automatic login checks
  Future<String?> getSavedToken() async {
    return await _secureStorage.readSecureData(_tokenKey);
  }
}
