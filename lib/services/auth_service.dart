import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:skincare_app/constant/api_constants.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/auth_model.dart';

/// Auth-related actions shared across screens (Profile tile, drawer, etc).
class AuthService {
  AuthService._();
  // Private constructor  
  // Static instance
  static final AuthService instance = AuthService._();

  static const String baseAuthUrl = '${ApiConstants.baseUrl}/auth';

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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
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
              style: TextStyle(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(
              AppString.logOutConfirmTitle,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // later: call the real sign-out endpoint here before navigating
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse(baseAuthUrl + '/register');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final decodedData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RegisterResponse.fromJson(decodedData);
      } else {
        return RegisterResponse(
          status: false,
          message:
              decodedData['message'] ??
              'Registration failed. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('Error during registration: $e');
      return RegisterResponse(
        status: false,
        message: 'Connection failed. Please check your network.',
      );
    }
  }


  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(baseAuthUrl + '/login');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final decodedData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(decodedData);
      } else {
        return LoginResponse(
          status: false,
          message:
              decodedData['message'] ??
              'Login failed. Please check your credentials.',
        );
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      return LoginResponse(
        status: false,
        message: 'Connection failed. Please check your network.',
      );
    }
  }
}
