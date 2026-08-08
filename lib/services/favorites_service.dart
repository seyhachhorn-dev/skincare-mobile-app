import 'package:flutter/foundation.dart';
import 'package:skincare_app/model/product.dart';

/// Holds the saved/wishlisted products for the current session and
/// notifies listeners (heart icons, bottom-nav, saved screen) on change.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final Map<String, Product> _saved = {};

  List<Product> get items => List.unmodifiable(_saved.values);

  bool isSaved(Product product) => _saved.containsKey(product.id);

  void toggle(Product product) {
    if (_saved.containsKey(product.id)) {
      _saved.remove(product.id);
    } else {
      _saved[product.id] = product;
    }
    notifyListeners();
  }

  void remove(Product product) {
    _saved.remove(product.id);
    notifyListeners();
  }
}
