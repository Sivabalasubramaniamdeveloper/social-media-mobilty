import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../instance/locator.dart';
import '../utils/snackbar_helper.dart';
import 'alice.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class CustomApiCallService {
  final Dio dio = dioProvider.dio;

  Future<Map<String, String>> _prepareHeaders(String? token) async {
    final TimezoneInfo timezoneInfo = await FlutterTimezone.getLocalTimezone();
    return {
      "Content-Type": "application/json",
      "TIMEZONE": timezoneInfo.identifier,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (token == null || token.isEmpty) 'x-Client-Type': 'mobile',
    };
  }

  /// Silently refreshes the access token using POST /auth/refresh
  Future<String?> _attemptTokenRefresh() async {
    try {
      final secureStorage = getIt<CustomSecureStorage>();
      final refreshToken = await secureStorage.readSecureData('refreshToken');

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // Use an isolated Dio instance to avoid recursive interceptor loops
      final refreshDio = Dio();
      final response = await refreshDio.post(
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
          await secureStorage.writeSecureData('loginToken', newAccessToken);

          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await secureStorage.writeSecureData(
              'refreshToken',
              newRefreshToken,
            );
          }

          try {
            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await Supabase.instance.client.auth.setSession(newRefreshToken);
            }
          } catch (_) {}

          return newAccessToken;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Response<dynamic>> makeApiRequest({
    required String method,
    required String token,
    required String url,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = await _prepareHeaders(token);
      Response response;
      switch (method) {
        case 'GET':
          response = await dio.get(url, options: Options(headers: headers));
          break;
        case 'POST':
          response = await dio.post(
            url,
            data: data,
            options: Options(headers: headers),
          );
          break;
        case 'PUT':
          response = await dio.put(
            url,
            data: data,
            options: Options(headers: headers),
          );
          break;
        case 'PATCH':
          response = await dio.patch(
            url,
            data: data,
            options: Options(headers: headers),
          );
          break;
        case 'DELETE':
          response = await dio.delete(
            url,
            data: data,
            options: Options(headers: headers),
          );
          break;
        default:
          throw Exception('Invalid HTTP method');
      }
      return response;
    } on DioException catch (e) {
      // -----------------------------------------------------------------
      // 401: Token Expired or Unauthorized -> Attempt Silent Refresh First
      // -----------------------------------------------------------------
      if (e.response?.statusCode == 401 && !url.contains('/auth/refresh')) {
        final newAccessToken = await _attemptTokenRefresh();

        // If refreshed successfully, retry the original request with the new token
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          return await makeApiRequest(
            method: method,
            token: newAccessToken,
            url: url,
            data: data,
          );
        }

        // If refresh failed or refresh token itself expired, show your session expired dialog
        final context = dioProvider.navigatorKey?.currentContext;
        if (context != null && context.mounted) {
          showCupertinoDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return PopScope(
                canPop: false,
                child: CupertinoAlertDialog(
                  title: Text(
                    AppStrings.sessionExpired,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.only(top: 8.0).r,
                    child: Text(
                      AppStrings.sessionExpiredDescription,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () async {
                        // 1. Clear secure storage tokens
                        final secureStorage = getIt<CustomSecureStorage>();
                        await secureStorage.deleteSecureData('loginToken');
                        await secureStorage.deleteSecureData('refreshToken');
                        await secureStorage.deleteAllSecureData();

                        try {
                          await Supabase.instance.client.auth.signOut();
                        } catch (_) {}

                        // 2. Dismiss dialog
                        if (dialogContext.mounted) {
                          Navigator.of(
                            dialogContext,
                            rootNavigator: true,
                          ).pop();
                        }

                        // 3. Navigate user to login screen
                        if (context.mounted) {
                          context.go(RouteNames.login);
                        }
                      },
                      child: Text(
                        AppStrings.continueLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        rethrow;
      } else if (e.response?.statusCode == 504 ||
          e.response?.statusCode == 500) {
        SnackBarHelper.showError(null, 'Something went wrong, please try again.');
        rethrow;
      } else if (e.response?.statusCode == 403) {
        // Let the login screen show the localized unverified-email message itself.
        if (e.response?.data['code'] != 'EMAIL_NOT_CONFIRMED') {
          SnackBarHelper.showError(
            null,
            e.response?.data['error'] ??
                e.response?.data['message'] ??
                'Forbidden',
          );
        }
        rethrow;
      } else {
        String? errorMessage =
            e.response?.data['error'] ?? e.response?.data['message'];
        if (errorMessage != null &&
            errorMessage != "Invalid mail format" &&
            errorMessage != "Invalid mobile number") {
          SnackBarHelper.showError(null, errorMessage);
        }
        rethrow;
      }
    }
  }
}
