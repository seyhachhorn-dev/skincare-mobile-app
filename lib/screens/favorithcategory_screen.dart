import 'package:flutter/material.dart';
import 'package:skincare_app/components/skipbutton.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

class FavoriteCategory extends StatefulWidget {
  const FavoriteCategory({super.key});

  @override
  State<FavoriteCategory> createState() => _FavoriteCategoryState();
}

class _FavoriteCategoryState extends State<FavoriteCategory> {
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

              const Text(
                AppString.chooseSub,
                textAlign: TextAlign.center,
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
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selected.remove(name);
                        } else {
                          selected.add(name);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    AppString.continueBtn,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SkipButton(
                onTap: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}