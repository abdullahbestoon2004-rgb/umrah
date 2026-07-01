import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';

/// One consistent snackbar style for the whole app.
void showAppSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(appSnack(message, isError: isError));
}

/// Use with a saved messenger when the calling context is about to be popped.
SnackBar appSnack(String message, {bool isError = false}) => SnackBar(
      content: Text(message, style: AppTheme.sans(13, weight: FontWeight.w600, color: Colors.white)),
      backgroundColor: isError ? AppColors.errorRed : AppColors.ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
