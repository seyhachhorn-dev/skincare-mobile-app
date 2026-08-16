import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_icons.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/product.dart';
import 'package:skincare_app/screens/product_detail_screen.dart';
import 'package:skincare_app/services/cart_service.dart';
import 'package:skincare_app/services/category_preference_service.dart';
import 'package:skincare_app/services/favorites_service.dart';
import 'package:skincare_app/services/product_service.dart';
import 'package:skincare_app/utils/money.dart';
import 'package:skincare_app/widgets/app_bottom_nav.dart';
import 'package:skincare_app/widgets/app_drawer.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';
import 'package:skincare_app/widgets/svg_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedFilter = 0;
  int currentTab = 0; // which bottom nav item is active

  final List<String> filters = ["Trending", "New Products"];

  String get _selectedSort => selectedFilter == 0 ? 'trending' : 'new';

  List<Product> products = [];
  bool _isLoading = true;
  bool _hasPreferredProducts = false;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    // Cart/favorites feed the bottom-nav badge and heart icons across
    // every screen, so they're loaded here too — this is the one screen
    // guaranteed to run early in every session (post-login/onboarding).
    final results = await Future.wait([
      ProductService.instance.list(sort: _selectedSort),
      CartService.instance.load(),
      FavoritesService.instance.load(),
      CategoryPreferenceService.loadCategoryIds(),
    ]);
    if (!mounted) return;

    final productResponse = results[0] as ProductListResponse;
    final preferredCategoryIds = results[3] as Set<int>;
    final orderedProducts = productResponse.status
        ? CategoryPreferenceService.prioritize(
            productResponse.products,
            preferredCategoryIds,
          )
        : <Product>[];
    setState(() {
      products = orderedProducts;
      _hasPreferredProducts = orderedProducts.any(
        (product) =>
            product.categoryId != null &&
            preferredCategoryIds.contains(product.categoryId),
      );
      _isLoading = false;
    });

    if (!productResponse.status) {
      AppSnackBar.error(
        context,
        title: 'Could not load products',
        message: productResponse.message.isNotEmpty
            ? productResponse.message
            : 'Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildSectionTitle(
                _hasPreferredProducts ? 'Picked for you' : AppString.browseCategory,
              ),
              _buildFilterChips(),
              _buildProductList(),
              _buildSectionTitle(AppString.productCollections),
              _buildCollectionRow(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentTab,
        onTap: (index) {
          setState(() => currentTab = index);
          if (index == 1) {
            Navigator.pushNamed(context, '/explore');
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

  // ---------- HEADER (menu, logo, bell) ----------
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
            AppString.brandName,
            style: TextStyle(
              fontSize: 18,
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
          hintText: AppString.searchHint,
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
            onTap: () {
              if (selectedFilter == index) return;
              setState(() => selectedFilter = index);
              _loadHome();
            },
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

  // ---------- HORIZONTAL PRODUCT CARDS ----------
  Widget _buildProductList() {
    if (_isLoading) {
      return const SizedBox(
        height: 340,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }
    if (products.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No products yet',
            style: TextStyle(color: AppColors.textGrey),
          ),
        ),
      );
    }
    return SizedBox(
      height: 400,
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
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
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => FavoritesService.instance.toggle(product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
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
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
            // text
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                        Money.usd(product.price),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: SvgIcon(
                            AppIcons.bag,
                            color: Colors.white,
                            size: 20,
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

  // ---------- COLLECTION ROW (small horizontal item) ----------
  Widget _buildCollectionRow() {
    if (products.isEmpty) return const SizedBox.shrink();
    final featured = products.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: featured.imageProvider,
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
                Text(
                  featured.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  featured.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
}
