import 'package:flutter/material.dart';
import 'package:mineai/core/utils/common_functions_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

showErrorToast(String message, {Toast toastLength = Toast.LENGTH_LONG}) {
  Fluttertoast.showToast(
    msg: message,
    timeInSecForIosWeb: 3,
    fontSize: 13.sp,
    toastLength: toastLength,
    textColor: Colors.white,
  );
}

showWarningToast(String message, {Toast toastLength = Toast.LENGTH_LONG}) {
  Fluttertoast.showToast(
    msg: message,
    timeInSecForIosWeb: 3,
    fontSize: 13.sp,
    toastLength: toastLength,
    textColor: Colors.white,
  );
}

showSuccessToast(String message, {Toast toastLength = Toast.LENGTH_LONG}) {
  Fluttertoast.showToast(
    msg: CommonFunctionsHelper.capitalizeFirstLetter(message),
    timeInSecForIosWeb: 3,
    fontSize: 13.sp,
    gravity: ToastGravity.BOTTOM,
    toastLength: toastLength,
  );
}

showToast(String message, {Toast toastLength = Toast.LENGTH_LONG}) {
  Fluttertoast.showToast(
    msg: message,
    webShowClose: true,
    fontSize: 13.sp,
    gravity: ToastGravity.TOP,
    toastLength: toastLength,
    backgroundColor: const Color(0xff444983),
    textColor: Colors.white,
  );
}
