import 'package:skincare_app/model/product.dart';

class OrderItem {
  final int id;
  final int quantity;
  final int unitPrice;
  final Product product;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price'] ?? 0,
      product: Product.fromJson(json['product']),
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final String status; // processing / delivered / cancelled
  final int total;
  final int pointsEarned;
  final String paymentMethod;
  final String paymentStatus; // pending / paid — only meaningfully "pending" for bakong_khqr
  final String shippingMethod;
  final int itemCount;
  final DateTime date;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.pointsEarned,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.shippingMethod,
    required this.itemCount,
    required this.date,
    this.items = const [],
  });

  bool get isPaid => paymentStatus == 'paid';

  String get statusLabel => status.isEmpty ? '' : '${status[0].toUpperCase()}${status.substring(1)}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get formattedDate => '${_months[date.month - 1]} ${date.day}, ${date.year}';

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? '',
      total: json['total'] ?? 0,
      pointsEarned: json['points_earned'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? 'paid',
      shippingMethod: json['shipping_method'] ?? '',
      itemCount: json['item_count'] ?? 0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      items: json['items'] != null
          ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
          : const [],
    );
  }
}

class OrderListResponse {
  final bool status;
  final String message;
  final List<Order> orders;

  OrderListResponse({required this.status, required this.message, this.orders = const []});

  factory OrderListResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return OrderListResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      orders: json['data'] != null ? (json['data'] as List).map((e) => Order.fromJson(e)).toList() : const [],
    );
  }
}

class OrderResponse {
  final bool status;
  final String message;
  final Order? order;

  OrderResponse({required this.status, required this.message, this.order});

  factory OrderResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return OrderResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      order: json['data'] != null ? Order.fromJson(json['data']) : null,
    );
  }
}
