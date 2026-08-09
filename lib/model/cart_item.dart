import 'package:skincare_app/model/product.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;

  CartItem({required this.id, required this.product, this.quantity = 1});

  int get total => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
    );
  }
}
