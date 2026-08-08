import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_icons.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/product.dart';
import 'package:skincare_app/widgets/svg_icon.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int currentTab = 1; // Explore tab active
  int selectedCategory = 0;
  int selectedFilter = 0;

  final List<String> filters = ["Trending", "New Products", "Highly Rated"];

  final List<Map<String, String>> categories = [
    {"icon": "🧴", "name": "All"},
    {"icon": "💧", "name": "Toner"},
    {"icon": "🌸", "name": "Serum"},
    {"icon": "🫗", "name": "Face Oil"},
    {"icon": "🧼", "name": "Cleanser"},
    {"icon": "☀️", "name": "Suncare"},
    {"icon": "💄", "name": "Makeup"},
  ];

  // Fake products for now — later this comes from your API
  final List<Product> products = [
    Product(
      name: "Granactive Retinoid 5%",
      description: "This water-free solution contains a 5% concentration of retinoid.",
      price: 699,
      image: "assets/images/pro1.png",
    ),
    Product(
      name: "Niacinamide 10% + Zinc",
      description: "A high-strength vitamin and mineral blemish formula.",
      price: 549,
      image: "assets/images/pro2.png",
    ),
    Product(
      name: "Hyaluronic Acid 2% + B5",
      description: "A hydration support formula with ultra-pure hyaluronic acid.",
      price: 629,
      image: "assets/images/pro3.png",
    ),
    Product(
      name: "Buffet + Copper Peptides",
      description: "Multi-technology peptide serum for visible signs of aging.",
      price: 899,
      image: "assets/images/pro4.jpg",
    ),
    Product(
      name: "Granactive Retinoid 2%",
      description: "A lighter-strength water-free solution with 2% retinoid.",
      price: 599,
      image: "assets/images/pro1.png",
    ),
    Product(
      name: "Ascorbyl Glucoside 12%",
      description: "A stable vitamin C solution to brighten and even skin tone.",
      price: 749,
      image: "assets/images/pro2.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategoryStrip()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              sliver: _buildProductGrid(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------- HEADER ----------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgIcon(AppIcons.menu, color: AppColors.textDark),
          const Text(
            AppString.exploreTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SvgIcon(AppIcons.notification, color: AppColors.textDark),
        ],
      ),
    );
  }

  // ---------- SEARCH BAR ----------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppString.exploreSearchHint,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgIcon(AppIcons.search, color: AppColors.textGrey, size: 20),
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

  // ---------- CATEGORY STRIP ----------
  Widget _buildCategoryStrip() {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isActive = selectedCategory == index;
          final category = categories[index];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = index),
            child: Container(
              width: 68,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.accent : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(category["icon"]!, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category["name"]!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.accent : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- FILTER CHIPS ----------
  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isActive = selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = index),
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

  // ---------- PRODUCT GRID ----------
  Widget _buildProductGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildProductCard(products[index]),
        childCount: products.length,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
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
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(product.image, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SvgIcon(AppIcons.heart, color: AppColors.accent, size: 14),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${product.price}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: SvgIcon(AppIcons.bag, color: Colors.white, size: 14),
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

  // ---------- BOTTOM NAV ----------
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentTab,
      onTap: (index) {
        setState(() => currentTab = index);
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textGrey,
      type: BottomNavigationBarType.fixed,
      items: [
        _navItem(AppIcons.home, "Home"),
        _navItem(AppIcons.explore, "Explore"),
        _navItem(AppIcons.heart, "Saved"),
        _navItem(AppIcons.bag, "Bag"),
        _navItem(AppIcons.profile, "Profile"),
      ],
    );
  }

  BottomNavigationBarItem _navItem(String asset, String label) {
    return BottomNavigationBarItem(
      icon: SvgIcon(asset, color: AppColors.textGrey),
      activeIcon: SvgIcon(asset, color: AppColors.accent),
      label: label,
    );
  }
}
