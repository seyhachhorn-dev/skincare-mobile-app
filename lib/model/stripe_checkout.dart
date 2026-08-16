class StripeCheckout {
  final int orderId;
  final String orderNumber;
  final String clientSecret;
  final int amount;
  final String currency;
  final String publishableKey;
  final String merchantDisplayName;

  StripeCheckout({
    required this.orderId,
    required this.orderNumber,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.publishableKey,
    required this.merchantDisplayName,
  });

  factory StripeCheckout.fromJson(Map<String, dynamic> json) {
    return StripeCheckout(
      orderId: json['order_id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      clientSecret: json['client_secret'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'usd',
      publishableKey: json['publishable_key'] ?? '',
      merchantDisplayName: json['merchant_display_name'] ?? 'Hinata Skincare',
    );
  }
}

class StripePaymentResponse {
  final bool status;
  final String message;
  final StripeCheckout? checkout;

  StripePaymentResponse({
    required this.status,
    required this.message,
    this.checkout,
  });
}
