import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skincare_app/constant/api_constants.dart';
import 'package:skincare_app/model/product.dart';

/// Product catalog reads against /api/products — public, no auth needed.
class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  static const String baseUrl = '${ApiConstants.baseUrl}/products';

  static const Map<String, String> _headers = {'Accept': 'application/json'};

  Future<ProductListResponse> list({
    String? search,
    int? categoryId,
    String? sort,
  }) async {
    final query = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': '$categoryId',
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };
    final url = Uri.parse(baseUrl).replace(queryParameters: query.isEmpty ? null : query);

    try {
      final response = await http.get(url, headers: _headers).timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      return ProductListResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return ProductListResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return ProductListResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }

  Future<ProductResponse> show(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/$id'), headers: _headers)
          .timeout(ApiConstants.requestTimeout);

      final decodedData = jsonDecode(response.body);
      final success = response.statusCode == 200;

      return ProductResponse.fromJson(decodedData, status: success);
    } on TimeoutException {
      return ProductResponse(status: false, message: 'The server took too long to respond.');
    } catch (e) {
      return ProductResponse(status: false, message: 'Connection failed. Please check your network.');
    }
  }
}
