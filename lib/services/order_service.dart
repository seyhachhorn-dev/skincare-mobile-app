import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skincare_app/constant/api_constants.dart';
import 'package:skincare_app/model/order.dart';
import 'package:skincare_app/services/auth_service.dart';

/// Order placement/history against /api/orders.
class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  static const String baseUrl = '${ApiConstants.baseUrl}/orders';

  Future<Map<String, String>?> _authHeaders() async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<OrderListResponse> list() async {
    final headers = await _authHeaders();
    if (headers == null) {
      return OrderListResponse(status: false, message: 'Not logged in.');
    }

    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: headers)
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      return OrderListResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return OrderListResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return OrderListResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }

  /// Places an order from the user's current server-side cart. The
  /// backend (never this request) decides line items/prices from
  /// whatever's actually in the cart, and empties it on success.
  Future<OrderResponse> placeOrder({
    required int addressId,
    required String paymentMethod,
    required String shippingMethod,
  }) async {
    final headers = await _authHeaders();
    if (headers == null) {
      return OrderResponse(status: false, message: 'Not logged in.');
    }

    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: headers,
            body: jsonEncode({
              'address_id': addressId,
              'payment_method': paymentMethod,
              'shipping_method': shippingMethod,
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 201;

      return OrderResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return OrderResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return OrderResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }
}
