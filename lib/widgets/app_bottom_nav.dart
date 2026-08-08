import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_icons.dart';
import 'package:skincare_app/services/cart_service.dart';
import 'package:skincare_app/widgets/svg_icon.dart';

/// Bottom navigation shared by Home, Explore, and Cart — keeps the Bag
/// item count badge in sync everywhere via [CartService].
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService.instance,
      builder: (context, _) {
        final bagCount = CartService.instance.itemCount;
        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textGrey,
          type: BottomNavigationBarType.fixed,
          items: [
            _navItem(AppIcons.home, "Home"),
            _navItem(AppIcons.explore, "Explore"),
            _navItem(AppIcons.heart, "Saved"),
            _navItem(AppIcons.bag, "Bag", badgeCount: bagCount),
            _navItem(AppIcons.profile, "Profile"),
          ],
        );
      },
    );
  }

  BottomNavigationBarItem _navItem(String asset, String label, {int badgeCount = 0}) {
    return BottomNavigationBarItem(
      icon: _icon(asset, AppColors.textGrey, badgeCount),
      activeIcon: _icon(asset, AppColors.accent, badgeCount),
      label: label,
    );
  }

  Widget _icon(String asset, Color color, int badgeCount) {
    final svg = SvgIcon(asset, color: color);
    if (badgeCount <= 0) return svg;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        svg,
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            child: Text(
              badgeCount > 9 ? "9+" : "$badgeCount",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
