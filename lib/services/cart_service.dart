import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:skincare_app/constant/api_constants.dart';
import 'package:skincare_app/model/cart_item.dart';
import 'package:skincare_app/model/product.dart';
import 'package:skincare_app/services/auth_service.dart';

/// Holds the shopping cart for the current session, backed by /api/cart,
/// and notifies listeners (bottom-nav badge, cart screen, checkout) on
/// change.
class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  static const String baseUrl = '${ApiConstants.baseUrl}/cart';

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  int get pointsEarned => (subtotal * 0.1).round();

  Future<Map<String, String>?> _authHeaders() async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetches the signed-in user's cart. Safe to call from every screen
  /// that shows it (Home/Explore for the badge, Cart, Checkout).
  Future<void> load() async {
    final headers = await _authHeaders();
    if (headers == null) return;

    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: headers)
          .timeout(ApiConstants.requestTimeout);
      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      final rawItems = decoded['data']['items'] as List;
      _items
        ..clear()
        ..addAll(rawItems.map((e) => CartItem.fromJson(e)));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  /// Adds a product to the cart. Unlike increment/decrement/removeItem,
  /// this is awaited by callers (see screens' _addToCart) rather than
  /// optimistic, because a new cart item's real id only exists after the
  /// server assigns one — there's nothing locally to show until then.
  /// Returns whether it actually succeeded, so the caller can show an
  /// honest success/error message instead of assuming success.
  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    final headers = await _authHeaders();
    if (headers == null) return false;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/items'),
            headers: headers,
            body: jsonEncode({'product_id': int.parse(product.id), 'quantity': quantity}),
          )
          .timeout(ApiConstants.requestTimeout);
      if (response.statusCode != 201) return false;

      final item = CartItem.fromJson(jsonDecode(response.body)['data']);
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        _items[index] = item;
      } else {
        _items.add(item);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    }
  }

  /// Optimistic quantity bump — reverts if the background PATCH fails.
  void increment(CartItem item) {
    final previous = item.quantity;
    item.quantity++;
    notifyListeners();
    _syncQuantity(item, previous);
  }

  void decrement(CartItem item) {
    if (item.quantity <= 1) {
      removeItem(item);
      return;
    }
    final previous = item.quantity;
    item.quantity--;
    notifyListeners();
    _syncQuantity(item, previous);
  }

  Future<void> _syncQuantity(CartItem item, int previousQuantity) async {
    final headers = await _authHeaders();
    if (headers == null) {
      item.quantity = previousQuantity;
      notifyListeners();
      return;
    }

    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/items/${item.id}'),
            headers: headers,
            body: jsonEncode({'quantity': item.quantity}),
          )
          .timeout(ApiConstants.requestTimeout);
      if (response.statusCode != 200) {
        item.quantity = previousQuantity;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating cart item quantity: $e');
      item.quantity = previousQuantity;
      notifyListeners();
    }
  }

  /// Optimistic removal — reinserts if the background DELETE fails.
  void removeItem(CartItem item) {
    final index = _items.indexOf(item);
    if (index == -1) return;
    _items.removeAt(index);
    notifyListeners();
    _syncRemoval(item, index);
  }

  Future<void> _syncRemoval(CartItem item, int previousIndex) async {
    final headers = await _authHeaders();
    if (headers == null) {
      _items.insert(previousIndex, item);
      notifyListeners();
      return;
    }

    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/items/${item.id}'), headers: headers)
          .timeout(ApiConstants.requestTimeout);
      if (response.statusCode != 200) {
        _items.insert(previousIndex, item);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error removing cart item: $e');
      _items.insert(previousIndex, item);
      notifyListeners();
    }
  }

  /// Called right after a successful order placement — the server
  /// already emptied the cart server-side (OrderService::placeOrder), so
  /// this just mirrors that locally instead of another round trip.
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Clears local state on logout so the next session doesn't briefly
  /// show the previous user's cart before load() runs.
  void reset() => clear();
}
