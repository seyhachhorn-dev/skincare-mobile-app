import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_icons.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/category.dart';
import 'package:skincare_app/model/product.dart';
import 'package:skincare_app/screens/product_detail_screen.dart';
import 'package:skincare_app/services/cart_service.dart';
import 'package:skincare_app/services/category_service.dart';
import 'package:skincare_app/services/favorites_service.dart';
import 'package:skincare_app/services/product_service.dart';
import 'package:skincare_app/utils/money.dart';
import 'package:skincare_app/widgets/app_bottom_nav.dart';
import 'package:skincare_app/widgets/app_drawer.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';
import 'package:skincare_app/widgets/svg_icon.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentTab = 1; // Explore tab active
  int selectedCategory = 0;
  int selectedFilter = 0;

  final List<String> filters = ["Trending", "New Products", "Highly Rated"];

  // "All" is synthesized locally (id: null) — the backend has no such
  // category, it just means "don't filter". Everything after it comes
  // from GET /api/categories; only the local Category.icon mapping
  // (Material Icons, not the backend's raw emoji) avoids the "tofu box"
  // rendering bug some Android devices hit on newer emoji glyphs.
  List<Category> categories = [Category(id: '', name: 'All')];
  List<Product> products = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadExplore();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExplore() async {
    final categoryResponse = await CategoryService.instance.list();
    if (!mounted) return;
    if (categoryResponse.status) {
      setState(
        () => categories = [
          Category(id: '', name: 'All'),
          ...categoryResponse.categories,
        ],
      );
    }
    await _loadProducts();
  }

  // Both search and category filtering are done server-side — GET
  // /api/products already supports combining `search` and `category_id`
  // in one query, so there's no separate client-side filter step.
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    final categoryId = selectedCategory == 0
        ? null
        : int.tryParse(categories[selectedCategory].id);
    final search = _searchController.text.trim();
    final response = await ProductService.instance.list(
      search: search.isEmpty ? null : search,
      categoryId: categoryId,
    );
    if (!mounted) return;

    setState(() {
      if (response.status) products = response.products;
      _isLoading = false;
    });

    if (!response.status) {
      AppSnackBar.error(
        context,
        title: 'Could not load products',
        message: response.message.isNotEmpty
            ? response.message
            : 'Please try again.',
      );
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentTab,
        onTap: (index) {
          setState(() => currentTab = index);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/saved');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/cart');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: SvgIcon(AppIcons.menu, color: AppColors.textDark),
          ),
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
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: AppString.exploreSearchHint,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgIcon(
              AppIcons.search,
              color: AppColors.textGrey,
              size: 20,
            ),
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
            onTap: () {
              if (selectedCategory == index) return;
              setState(() => selectedCategory = index);
              _loadProducts();
            },
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
                      child: Icon(
                        category.icon,
                        size: 24,
                        color: isActive ? Colors.white : AppColors.textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
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

  // ---------- ADD TO CART (quick-add from the product card) ----------
  Future<void> _addToCart(Product product) async {
    final added = await CartService.instance.addToCart(product);
    if (!mounted) return;
    if (added) {
      AppSnackBar.success(
        context,
        title: 'Added to bag',
        message: '${product.name} added to your bag',
      );
    } else {
      AppSnackBar.error(
        context,
        title: "Couldn't add to bag",
        message: 'Please try again.',
      );
    }
  }

  // ---------- PRODUCT GRID ----------
  Widget _buildProductGrid() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );
    }
    if (products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'No products found',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
        ),
      );
    }
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image(
                      image: product.imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => FavoritesService.instance.toggle(product),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ListenableBuilder(
                          listenable: FavoritesService.instance,
                          builder: (context, _) => SvgIcon(
                            AppIcons.heart,
                            color: FavoritesService.instance.isSaved(product)
                                ? AppColors.accent
                                : AppColors.textGrey,
                            size: 14,
                          ),
                        ),
                      ),
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
                        Money.usd(product.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: SvgIcon(
                            AppIcons.bag,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
