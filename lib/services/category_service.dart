import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skincare_app/constant/api_constants.dart';
import 'package:skincare_app/model/category.dart';

/// Category reads against /api/categories — public, no auth needed.
class CategoryService {
  CategoryService._();
  static final CategoryService instance = CategoryService._();

  static const String baseUrl = '${ApiConstants.baseUrl}/categories';

  Future<CategoryListResponse> list() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: const {'Accept': 'application/json'})
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      return CategoryListResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return CategoryListResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return CategoryListResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }
}
