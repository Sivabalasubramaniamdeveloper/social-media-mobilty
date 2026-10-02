import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import '../../instance/locator.dart';
import '../utils/toast_helper.dart';
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
      // 401: Token Expired or Unauthorized -> Clear storage and Logout
      // -----------------------------------------------------------------
      if (e.response?.statusCode == 401) {
        final context = dioProvider.navigatorKey?.currentContext;
        if (context != null) {
          showCupertinoDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return PopScope(
                canPop: false,
                child: CupertinoAlertDialog(
                  title: const Text(
                    'Session Expired',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.only(top: 8.0).r,
                    child: Text(
                      'Your session has expired. Please login again to continue.',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () async {
                        // 1. Clear secure storage token
                        final secureStorage = getIt<CustomSecureStorage>();
                        await secureStorage.deleteSecureData('loginToken');
                        await secureStorage.deleteAllSecureData();

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
                        'Continue',
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
        showErrorToast('Something went wrong, please try again.');
        rethrow;
      } else if (e.response?.statusCode == 403) {
        await showErrorToast(
          e.response?.data['error'] ??
              e.response?.data['message'] ??
              'Forbidden',
        );
        rethrow;
      } else {
        String? errorMessage =
            e.response?.data['error'] ?? e.response?.data['message'];
        if (errorMessage != null &&
            errorMessage != "Invalid mail format" &&
            errorMessage != "Invalid mobile number") {
          showErrorToast(errorMessage);
        }
        rethrow;
      }
    }
  }
}
