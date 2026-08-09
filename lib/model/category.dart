import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  /// The backend's `icon` field is a raw emoji, which is deliberately
  /// ignored here — several of those glyphs render as blank "tofu" boxes
  /// on Android devices whose OEM font is missing them (see
  /// favorithcategory_screen.dart/explore_screen.dart for the same fix).
  /// Material Icons are bundled with Flutter, so they render identically
  /// everywhere regardless of what the backend sends.
  IconData get icon => _iconByName[name.toLowerCase()] ?? Icons.category_outlined;

  static const Map<String, IconData> _iconByName = {
    'all': Icons.apps_rounded,
    'toner': Icons.water_drop_outlined,
    'serum': Icons.science_outlined,
    'face oil': Icons.opacity_outlined,
    'cleanser': Icons.clean_hands_outlined,
    'suncare': Icons.wb_sunny_outlined,
    'makeup': Icons.brush_outlined,
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: '${json['id']}', name: json['name'] ?? '');
  }
}

class CategoryListResponse {
  final bool status;
  final String message;
  final List<Category> categories;

  CategoryListResponse({required this.status, required this.message, this.categories = const []});

  factory CategoryListResponse.fromJson(Map<String, dynamic> json, {required bool status}) {
    return CategoryListResponse(
      status: status,
      message: json['message'] ?? 'Unknown error occurred',
      categories: json['data'] != null
          ? (json['data'] as List).map((e) => Category.fromJson(e)).toList()
          : const [],
    );
  }
}
