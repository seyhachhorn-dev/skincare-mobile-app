import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // ---------- TOKEN STORAGE ----------

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.tokenKey);
  }

  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
  }

  static Future<bool> isLoggedIn() async => (await getToken()) != null;

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

    // Best-effort: revoke the token server-side, but don't block the user
    // from logging out locally if the network call fails/times out.
    await instance._revokeToken();
    await _clearToken();

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _revokeToken() async {
    final token = await getToken();
    if (token == null) return;
    try {
      await http.post(
        Uri.parse('$baseAuthUrl/logout'),
        headers: {..._jsonHeaders, 'Authorization': 'Bearer $token'},
      ).timeout(ApiConstants.requestTimeout);
    } catch (e) {
      debugPrint('Error revoking token on logout: $e');
    }
  }

  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse('$baseAuthUrl/register');
      final response = await http
          .post(
            url,
            headers: _jsonHeaders,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200 || response.statusCode == 201;

      return RegisterResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return RegisterResponse(
        status: false,
        message: 'The server took too long to respond. Check your connection and try again.',
      );
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
      final url = Uri.parse('$baseAuthUrl/login');
      final response = await http
          .post(
            url,
            headers: _jsonHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      final result = LoginResponse.fromJson(decodedData, status: success);

      if (success && result.token != null) {
        await _saveToken(result.token!);
      }

      return result;
    } on TimeoutException {
      return LoginResponse(
        status: false,
        message: 'The server took too long to respond. Check your connection and try again.',
      );
    } catch (e) {
      debugPrint('Error during login: $e');
      return LoginResponse(
        status: false,
        message: 'Connection failed. Please check your network.',
      );
    }
  }

  /// Fetches the current user from GET /auth/me using the stored token.
  Future<MeResponse> me() async {
    final token = await getToken();
    if (token == null) {
      return MeResponse(status: false, message: 'Not logged in.');
    }

    try {
      final url = Uri.parse('$baseAuthUrl/me');
      final response = await http.get(
        url,
        headers: {..._jsonHeaders, 'Authorization': 'Bearer $token'},
      ).timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      return MeResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return MeResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      return MeResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }
}
