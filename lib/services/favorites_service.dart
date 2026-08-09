import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:skincare_app/constant/api_constants.dart';
import 'package:skincare_app/model/product.dart';
import 'package:skincare_app/services/auth_service.dart';

/// Holds the saved/wishlisted products for the current session, backed by
/// /api/favorites, and notifies listeners (heart icons, bottom-nav, saved
/// screen) on change.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  static const String baseUrl = '${ApiConstants.baseUrl}/favorites';

  final Map<String, Product> _saved = {};

  List<Product> get items => List.unmodifiable(_saved.values);

  bool isSaved(Product product) => _saved.containsKey(product.id);

  Future<Map<String, String>?> _authHeaders() async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetches the signed-in user's saved products. Cheap to call from
  /// every screen that displays favorites (Home, Explore, Saved) — it's
  /// just a GET, and keeps local state fresh across app restarts/logins.
  Future<void> load() async {
    final headers = await _authHeaders();
    if (headers == null) return;

    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: headers)
          .timeout(ApiConstants.requestTimeout);
      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      final products = (decoded['data'] as List).map((e) => Product.fromJson(e));
      _saved
        ..clear()
        ..addEntries(products.map((p) => MapEntry(p.id, p)));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  /// Toggles locally first so the heart icon responds instantly, then
  /// syncs to the server in the background; reverts on failure. No
  /// BuildContext is available here to surface an error, so a failed
  /// sync is silent — same best-effort tradeoff as
  /// AuthService.logout()'s token revocation.
  void toggle(Product product) {
    final wasSaved = _saved.containsKey(product.id);
    if (wasSaved) {
      _saved.remove(product.id);
    } else {
      _saved[product.id] = product;
    }
    notifyListeners();

    _sync(product, add: !wasSaved, wasSaved: wasSaved);
  }

  void remove(Product product) {
    if (!_saved.containsKey(product.id)) return;
    _saved.remove(product.id);
    notifyListeners();

    _sync(product, add: false, wasSaved: true);
  }

  Future<void> _sync(Product product, {required bool add, required bool wasSaved}) async {
    final headers = await _authHeaders();
    if (headers == null) {
      _revert(product, wasSaved);
      return;
    }

    try {
      final response = add
          ? await http
              .post(Uri.parse(baseUrl), headers: headers, body: jsonEncode({'product_id': int.parse(product.id)}))
              .timeout(ApiConstants.requestTimeout)
          : await http
              .delete(Uri.parse('$baseUrl/${product.id}'), headers: headers)
              .timeout(ApiConstants.requestTimeout);

      final ok = add ? response.statusCode == 201 : response.statusCode == 200;
      if (!ok) _revert(product, wasSaved);
    } catch (e) {
      debugPrint('Error syncing favorite: $e');
      _revert(product, wasSaved);
    }
  }

  void _revert(Product product, bool wasSaved) {
    if (wasSaved) {
      _saved[product.id] = product;
    } else {
      _saved.remove(product.id);
    }
    notifyListeners();
  }

  /// Clears local state on logout so the next session doesn't briefly
  /// show the previous user's saved products before load() runs.
  void reset() {
    _saved.clear();
    notifyListeners();
  }
}
