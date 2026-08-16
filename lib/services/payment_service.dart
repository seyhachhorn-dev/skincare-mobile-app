import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skincare_app/constant/api_constants.dart';
import 'package:skincare_app/model/khqr_payment.dart';
import 'package:skincare_app/services/auth_service.dart';

/// Bakong KHQR payment flow against /api/orders/{order}/khqr.
class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  Future<Map<String, String>?> _authHeaders() async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Generates (or re-fetches, if called again before payment) the KHQR
  /// code for an order already placed with payment_method=bakong_khqr.
  Future<KhqrPaymentResponse> generateKhqr(int orderId) async {
    final headers = await _authHeaders();
    if (headers == null) {
      return KhqrPaymentResponse(status: false, message: 'Not logged in.');
    }

    try {
      final response = await http
          .post(Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/khqr'), headers: headers)
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      return KhqrPaymentResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return KhqrPaymentResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return KhqrPaymentResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }

  /// Abandons a still-unpaid KHQR order. The server releases its items
  /// back into the user's cart and reverses the points it speculatively
  /// credited at order-placement time — callers should resync the local
  /// cart (CartService.load()) after this succeeds.
  Future<KhqrCancelResponse> cancelKhqr(int orderId) async {
    final headers = await _authHeaders();
    if (headers == null) {
      return KhqrCancelResponse(status: false, message: 'Not logged in.');
    }

    try {
      final response = await http
          .post(Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/khqr/cancel'), headers: headers)
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      return KhqrCancelResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return KhqrCancelResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return KhqrCancelResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }

  /// Meant to be polled while the KHQR code is on screen.
  Future<KhqrStatusResponse> checkKhqrStatus(int orderId) async {
    final headers = await _authHeaders();
    if (headers == null) {
      return KhqrStatusResponse(status: false, message: 'Not logged in.');
    }

    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/khqr/status'), headers: headers)
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      return KhqrStatusResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return KhqrStatusResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return KhqrStatusResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }
}
