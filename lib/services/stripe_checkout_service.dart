import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:skincare_app/constant/api_constants.dart';
import 'package:skincare_app/model/stripe_checkout.dart';
import 'package:skincare_app/services/auth_service.dart';
import 'package:skincare_app/utils/money.dart';

/// Starts and presents a server-created Stripe PaymentIntent. The app never
/// sends card data to the Laravel API and never marks an order paid itself.
class StripeCheckoutService {
  StripeCheckoutService._();
  static final StripeCheckoutService instance = StripeCheckoutService._();

  static const String _checkoutUrl = '${ApiConstants.baseUrl}/checkout';

  Future<Map<String, String>?> _authHeaders() async {
    final token = await AuthService.getToken();
    if (token == null) return null;

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<StripePaymentResponse> pay({
    required int addressId,
    required String shippingMethod,
  }) async {
    if (!_supportsPaymentSheet) {
      return StripePaymentResponse(
        status: false,
        message:
            'Card payments open in the Android or iPhone app. Windows can preview checkout but cannot show Stripe PaymentSheet.',
      );
    }

    final headers = await _authHeaders();
    if (headers == null) {
      return StripePaymentResponse(status: false, message: 'Not logged in.');
    }

    StripeCheckout? checkout;
    try {
      final response = await http
          .post(
            Uri.parse(_checkoutUrl),
            headers: headers,
            body: jsonEncode({
              'address_id': addressId,
              'shipping_method': shippingMethod,
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201 || decodedData['data'] == null) {
        return StripePaymentResponse(
          status: false,
          message: decodedData['message'] ?? 'Could not start card payment.',
        );
      }

      checkout = StripeCheckout.fromJson(decodedData['data']);
      if (checkout.clientSecret.isEmpty || checkout.publishableKey.isEmpty) {
        return StripePaymentResponse(
          status: false,
          message: 'Invalid Stripe checkout response.',
        );
      }

      Stripe.publishableKey = checkout.publishableKey;
      Stripe.urlScheme = 'skincare';
      await Stripe.instance.applySettings();
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: checkout.merchantDisplayName,
          paymentIntentClientSecret: checkout.clientSecret,
          returnURL: 'skincare://stripe-redirect',
          allowsDelayedPaymentMethods: true,
          primaryButtonLabel:
              'Pay ${_formatAmount(checkout.amount, checkout.currency)}',
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // PaymentSheet only completes the device-side flow. The Stripe webhook
      // is the source of truth for payment_status=paid and fulfillment.
      return StripePaymentResponse(
        status: true,
        message: 'Payment submitted for confirmation.',
        checkout: checkout,
      );
    } on StripeException catch (error) {
      if (checkout != null) {
        await _cancelPendingCheckout(checkout.orderId, headers);
      }
      return StripePaymentResponse(
        status: false,
        message: error.error.localizedMessage ?? 'Card payment was cancelled.',
      );
    } on TimeoutException {
      return StripePaymentResponse(
        status: false,
        message: 'The server took too long to respond.',
      );
    } catch (_) {
      return StripePaymentResponse(
        status: false,
        message: 'Could not complete card payment. Please try again.',
      );
    }
  }

  Future<void> _cancelPendingCheckout(
    int orderId,
    Map<String, String> headers,
  ) async {
    try {
      await http
          .post(Uri.parse('$_checkoutUrl/$orderId/cancel'), headers: headers)
          .timeout(ApiConstants.requestTimeout);
    } catch (_) {
      // The order remains pending if Stripe cannot confirm its cancellation.
      // It must never be treated as paid by the Flutter client.
    }
  }

  String _formatAmount(int amount, String currency) {
    if (currency.toLowerCase() == 'usd') {
      return Money.usdCents(amount);
    }

    final value = (amount / 100).toStringAsFixed(2);
    return '${currency.toUpperCase()} $value';
  }

  bool get _supportsPaymentSheet =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
