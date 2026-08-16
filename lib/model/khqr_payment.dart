class KhqrPayment {
  final String qr;
  final String md5;
  final String merchantName;

  KhqrPayment({required this.qr, required this.md5, required this.merchantName});

  factory KhqrPayment.fromJson(Map<String, dynamic> json) {
    return KhqrPayment(
      qr: json['qr'] ?? '',
      md5: json['md5'] ?? '',
      merchantName: json['merchant_name'] ?? '',
    );
  }
}

class KhqrPaymentResponse {
  final bool status;
  final String message;
  final KhqrPayment? payment;

  KhqrPaymentResponse({required this.status, required this.message, this.payment});

  factory KhqrPaymentResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return KhqrPaymentResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      payment: json['data'] != null ? KhqrPayment.fromJson(json['data']) : null,
    );
  }
}

class KhqrCancelResponse {
  final bool status;
  final String message;

  KhqrCancelResponse({required this.status, required this.message});

  factory KhqrCancelResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return KhqrCancelResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
    );
  }
}

class KhqrStatusResponse {
  final bool status;
  final String message;
  final bool paid;

  KhqrStatusResponse({required this.status, required this.message, this.paid = false});

  factory KhqrStatusResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return KhqrStatusResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      paid: json['data'] != null ? (json['data']['paid'] ?? false) : false,
    );
  }
}
