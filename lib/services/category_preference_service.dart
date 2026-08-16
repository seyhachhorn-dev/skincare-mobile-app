import 'package:shared_preferences/shared_preferences.dart';
import 'package:skincare_app/model/product.dart';

/// Stores the categories a shopper chooses during onboarding and uses them to
/// put relevant products first without hiding the rest of the catalog.
class CategoryPreferenceService {
  CategoryPreferenceService._();

  static const _preferredCategoryIdsKey = 'preferred_category_ids';

  static Future<void> saveCategoryIds(Iterable<String> categoryIds) async {
    final preferences = await SharedPreferences.getInstance();
    final ids = categoryIds
        .map(int.tryParse)
        .whereType<int>()
        .map((id) => id.toString())
        .toSet()
        .toList();
    await preferences.setStringList(_preferredCategoryIdsKey, ids);
  }

  static Future<Set<int>> loadCategoryIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences
        .getStringList(_preferredCategoryIdsKey)
        ?.map(int.tryParse)
        .whereType<int>()
        .toSet() ??
        <int>{};
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_preferredCategoryIdsKey);
  }

  /// Keeps the server's original order inside each group. Products matching a
  /// chosen category are placed first, followed by every other product.
  static List<Product> prioritize(
    Iterable<Product> products,
    Set<int> preferredCategoryIds,
  ) {
    if (preferredCategoryIds.isEmpty) return List<Product>.from(products);

    final preferred = <Product>[];
    final remaining = <Product>[];
    for (final product in products) {
      if (product.categoryId != null &&
          preferredCategoryIds.contains(product.categoryId)) {
        preferred.add(product);
      } else {
        remaining.add(product);
      }
    }
    return [...preferred, ...remaining];
  }
}
