import 'package:flutter/material.dart';
import 'package:skincare_app/constant/api_constants.dart';

class Product {
  final String id;
  final int? categoryId;
  final String name;
  final String description;
  final int price;
  final String image; // bundled asset path (seed data) or API-relative storage path
  final String brand;
  final String size;

  Product({
    required this.id,
    this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.brand = '',
    this.size = '',
  });

  /// Resolves [image] to whatever Flutter needs to actually paint it.
  /// Seeded products ship as bundled assets (`assets/images/pro1.png`);
  /// anything created through the admin upload endpoint is a relative
  /// storage path (`products/xyz.png`) that has to be resolved against
  /// the same host `ApiConstants.baseUrl` points at (not `APP_URL` —
  /// those differ on a physical device using a LAN IP).
  ImageProvider get imageProvider {
    if (image.startsWith('assets/')) return AssetImage(image);
    if (image.startsWith('http')) return NetworkImage(image);
    final host = ApiConstants.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return NetworkImage('$host/storage/$image');
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: '${json['id']}',
      categoryId: json['category_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'] ?? '',
      brand: json['brand'] ?? '',
      size: json['size'] ?? '',
    );
  }
}

class ProductListResponse {
  final bool status;
  final String message;
  final List<Product> products;

  ProductListResponse({required this.status, required this.message, this.products = const []});

  factory ProductListResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return ProductListResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      products: json['data'] != null
          ? (json['data'] as List).map((e) => Product.fromJson(e)).toList()
          : const [],
    );
  }
}

class ProductResponse {
  final bool status;
  final String message;
  final Product? product;

  ProductResponse({required this.status, required this.message, this.product});

  factory ProductResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return ProductResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      product: json['data'] != null ? Product.fromJson(json['data']) : null,
    );
  }
}
