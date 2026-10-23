import 'package:flutter/material.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';

void showErrorToast(String message, {dynamic toastLength}) {
  SnackBarHelper.showError(null, message);
}

void showWarningToast(String message, {dynamic toastLength}) {
  SnackBarHelper.showWarning(null, message);
}

void showSuccessToast(String message, {dynamic toastLength}) {
  SnackBarHelper.showSuccess(null, message);
}

void showToast(String message, {dynamic toastLength, dynamic gravity, Color? backgroundColor, Color? textColor}) {
  SnackBarHelper.showInfo(null, message);
}
