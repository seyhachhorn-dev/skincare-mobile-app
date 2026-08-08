import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_icons.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int selectedCategory = 0; // which filter chip is active
  int currentTab = 0;       // which bottom nav item is active

  final List<String> filters = ["Trending", "New Products", "Highly Rated"];

  // Fake products for now — later this comes from your API
  final List<Product> products = [
    Product(
      name: "Granactive Retinoid 5%",
      description: "This water-free solution contains a 5% concentration of retinoid.",
      price: 699,
      image: "assets/images/pro1.png",
    ),
    Product(
      name: "Granactive Retinoid 5%",
      description: "This water-free solution contains a 5% concentration of retinoid.",
      price: 699,
      image: "assets/images/pro2.png",
    ),
    Product(
      name: "Granactive Retinoid 5%",
      description: "This water-free solution contains a 5% concentration of retinoid.",
      price: 699,
      image: "assets/images/pro3.png",
    ),
    Product(
      name: "Granactive Retinoid 5%",
      description: "This water-free solution contains a 5% concentration of retinoid.",
      price: 699,
      image: "assets/images/pro4.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildHeader(),
              _buildSearchBar(),
              _buildSectionTitle(AppString.browseCategory),
              _buildFilterChips(),
              _buildProductList(),
              _buildSectionTitle(AppString.productCollections),
              _buildCollectionRow(),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------- HEADER (menu, logo, bell) ----------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _svgIcon(AppIcons.menu, color: AppColors.textDark),
          const Text(
            AppString.brandName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          _svgIcon(AppIcons.notification, color: AppColors.textDark),
        ],
      ),
    );
  }

  // ---------- SVG ICON HELPER (Figma-exported icons) ----------
  Widget _svgIcon(String asset, {required Color color, double size = 24}) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // ---------- SEARCH BAR ----------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppString.searchHint,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: _svgIcon(AppIcons.search, color: AppColors.textGrey, size: 20),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------- SECTION TITLE + View all ----------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const Text(
            AppString.viewAll,
            style: TextStyle(
              color: AppColors.textGrey,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- FILTER CHIPS (Trending / New / Rated) ----------
  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isActive = selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isActive ? AppColors.accent : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isActive ? AppColors.accent : AppColors.textGrey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- HORIZONTAL PRODUCT CARDS ----------
  Widget _buildProductList() {
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image + heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  product.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: _svgIcon(AppIcons.heart, color: AppColors.accent, size: 18),
                ),
              ),
            ],
          ),
          // text
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${product.price}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: _svgIcon(AppIcons.bag, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COLLECTION ROW (small horizontal item) ----------
  Widget _buildCollectionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              "assets/images/pro1.png",
              width: 90,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Granactive Retinoid 5%",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "This water-free solution contains a 5%...",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- BOTTOM NAV ----------
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentTab,
      onTap: (index) => setState(() => currentTab = index),
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textGrey,
      type: BottomNavigationBarType.fixed,
      items: [
        _navItem(AppIcons.home, "Home"),
        _navItem(AppIcons.explore, "Explore"),
        _navItem(AppIcons.heart, "Saved"),
        _navItem(AppIcons.profile, "Profile"),
      ],
    );
  }

  BottomNavigationBarItem _navItem(String asset, String label) {
    return BottomNavigationBarItem(
      icon: _svgIcon(asset, color: AppColors.textGrey),
      activeIcon: _svgIcon(asset, color: AppColors.accent),
      label: label,
    );
  }
}