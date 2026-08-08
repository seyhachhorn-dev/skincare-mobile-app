import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

/// Auth-related actions shared across screens (Profile tile, drawer, etc).
class AuthService {
  AuthService._();

  /// Confirms with the user, then clears the navigation stack back to
  /// the login screen. No-op if the user cancels.
  static Future<void> logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          AppString.logOutConfirmTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        content: const Text(
          AppString.logOutConfirmMessage,
          style: TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              AppString.cancel,
              style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppString.logOutConfirmTitle, style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // later: call the real sign-out endpoint here before navigating
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
