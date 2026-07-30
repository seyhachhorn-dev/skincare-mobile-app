import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

class FavoriteCategory extends StatefulWidget {
  const FavoriteCategory({super.key});

  @override
  State<FavoriteCategory> createState() => _FavoriteCategoryState();
}

class _FavoriteCategoryState extends State<FavoriteCategory> {
  // The list of all categories with their emoji icon
  final List<Map<String, String>> categories = [
    {"icon": "🧴", "name": "Show All"},
    {"icon": "🌸", "name": "Perfume"},
    {"icon": "🧴", "name": "Moisturizer"},
    {"icon": "🧴", "name": "Shampoo"},
    {"icon": "🎁", "name": "Gift Cards"},
    {"icon": "💧", "name": "Toner"},
    {"icon": "🫗", "name": "Face oils"},
    {"icon": "💄", "name": "Foundation"},
    {"icon": "🧴", "name": "Suncare"},
    {"icon": "🪮", "name": "Tools"},
  ];

  // Keeps track of which categories the user tapped
  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                AppString.chooseCategory,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  const Text(
                    AppString.chooseSub,
                    style: TextStyle(fontSize: 15, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 32),

                  // CATEGORY CHIPS (2 per row)
                  Wrap(
                    spacing: 16, // for horizental
                    runSpacing: 16, //for vertical gap
                     
                    alignment: WrapAlignment.center,
                    children: categories.map((category) {
                      final name = category["name"]!;
                      final icon = category["icon"]!;
                      final isSelected = selected.contains(name);
                      return GestureDetector(
                        onTap: () {},
                        child: const SizedBox(),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
