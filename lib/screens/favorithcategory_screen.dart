import 'package:flutter/material.dart';
import 'package:skincare_app/components/skipbutton.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

class FavoriteCategory extends StatefulWidget {
  const FavoriteCategory({super.key});

  @override
  State<FavoriteCategory> createState() => _FavoriteCategoryState();
}

class _CategoryOption {
  final IconData icon;
  final String name;
  const _CategoryOption(this.icon, this.name);
}

class _FavoriteCategoryState extends State<FavoriteCategory> {
  // Material Icons instead of raw emoji — emoji glyphs depend on the
  // device's OS/OEM font, and several here (🧴 lotion bottle, 🪮 hair pick)
  // are recent enough Unicode additions that many Android devices render
  // them as blank "tofu" boxes. Icons are bundled with Flutter itself, so
  // they render identically on every device.
  final List<_CategoryOption> categories = const [
    _CategoryOption(Icons.apps_rounded, "Show All"),
    _CategoryOption(Icons.local_florist_outlined, "Perfume"),
    _CategoryOption(Icons.spa_outlined, "Moisturizer"),
    _CategoryOption(Icons.shower_outlined, "Shampoo"),
    _CategoryOption(Icons.card_giftcard_outlined, "Gift Cards"),
    _CategoryOption(Icons.water_drop_outlined, "Toner"),
    _CategoryOption(Icons.opacity_outlined, "Face oils"),
    _CategoryOption(Icons.brush_outlined, "Foundation"),
    _CategoryOption(Icons.wb_sunny_outlined, "Suncare"),
    _CategoryOption(Icons.build_outlined, "Tools"),
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
                  final name = category.name;
                  final icon = category.icon;
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
                          Icon(
                            icon,
                            size: 20,
                            color: isSelected ? Colors.white : AppColors.textDark,
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