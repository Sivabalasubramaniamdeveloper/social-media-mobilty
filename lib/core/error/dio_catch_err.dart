import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class DioCatchError{
  // static void dioExceptionError(
  //     DioException err,
  //     BuildContext context,
  //     ) async {
  //   switch (err.type) {
  //     case DioExceptionType.connectionTimeout:
  //       showToastMessage(context, err.type.name, isError: true);
  //     case DioExceptionType.sendTimeout:
  //       showToastMessage(context, err.type.name, isError: true);
  //     case DioExceptionType.receiveTimeout:
  //       showToastMessage(context, err.type.name, isError: true);
  //     case DioExceptionType.badCertificate:
  //       showToastMessage(context, err.type.name, isError: true);
  //     case DioExceptionType.badResponse:
  //       if (err.response!.statusCode == 400) {
  //         showToastMessage(
  //           context,
  //           err.response!.data![JsonKeys.message] ??
  //               err.response!.statusMessage,
  //           isError: true,
  //         );
  //       } else if (err.response!.statusCode == 401) {
  //         deBugPrint('token expired');
  //         deBugPrint('+++++++++++++++++++++++');
  //
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //         await prefs.remove(JsonKeys.token);
  //
  //         if (context.mounted) {
  //           Navigator.pushNamedAndRemoveUntil(
  //               context, AppRoutes.initial, ModalRoute.withName('/'));
  //           showToastMessage(
  //             context,
  //             err.response!.data![JsonKeys.message] ??
  //                 err.response!.statusMessage,
  //             isError: true,
  //           );
  //         }
  //       } else if (err.response!.statusCode == 403) {
  //         showToastMessage(
  //           context,
  //           err.response!.data![JsonKeys.message] ??
  //               err.response!.statusMessage,
  //           isError: true,
  //         );
  //       } else if (err.response!.statusCode == 404) {
  //         showToastMessage(
  //           context,
  //           err.response!.data![JsonKeys.message] ??
  //               err.response!.statusMessage,
  //           isError: true,
  //         );
  //       } else if (err.response!.statusCode == 500) {
  //         showToastMessage(
  //           context,
  //           err.response!.data![JsonKeys.message] ??
  //               err.response!.statusMessage,
  //           isError: true,
  //         );
  //       } else if (err.response!.statusCode == 502) {
  //         showToastMessage(
  //           context,
  //           err.response!.data![JsonKeys.message] ??
  //               err.response!.statusMessage,
  //           isError: true,
  //         );
  //       } else if (err.response!.statusCode == 503) {
  //         showToastMessage(
  //           context,
  //           err.response!.data![JsonKeys.message] ??
  //               err.response!.statusMessage,
  //           isError: true,
  //         );
  //       }
  //     case DioExceptionType.cancel:
  //       showToastMessage(context, err.type.name, isError: true);
  //     case DioExceptionType.connectionError:
  //       showToastMessage(context, err.type.name, isError: true);
  //     case DioExceptionType.unknown:
  //       showToastMessage(context, err.type.name, isError: true);
  //   }
  // }
}