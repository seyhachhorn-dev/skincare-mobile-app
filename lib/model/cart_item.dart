import 'package:skincare_app/model/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get total => product.price * quantity;
}
