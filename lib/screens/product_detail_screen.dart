import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_icons.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/product.dart';
import 'package:skincare_app/services/cart_service.dart';
import 'package:skincare_app/services/favorites_service.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';
import 'package:skincare_app/widgets/svg_icon.dart';

/// Full-screen product detail page — works for any [Product] passed to it.
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _imageController = PageController();
  int _imageIndex = 0;
  int _quantity = 1;
  bool _detailsExpanded = false;
  bool _shippingExpanded = false;

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = [widget.product.image];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            width: double.infinity,
            child: _buildImageCarousel(images),
          ),
          Expanded(child: _buildDetailsPanel()),
        ],
      ),
    );
  }

  // ---------- IMAGE CAROUSEL ----------
  Widget _buildImageCarousel(List<String> images) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _imageController,
          itemCount: images.length,
          onPageChanged: (index) => setState(() => _imageIndex = index),
          itemBuilder: (context, index) => Image.asset(images[index], fit: BoxFit.cover),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          child: _buildCircleButton(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = index == _imageIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.textDark),
      ),
    );
  }

  // ---------- DETAILS PANEL (fills remaining space; CTA pinned to bottom) ----------
  Widget _buildDetailsPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildProductInfo(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: _buildBottomActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final product = widget.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.brand.isNotEmpty) ...[
          Text(
            product.brand.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "\$${product.price}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (product.size.isNotEmpty) _buildLabeledValue(AppString.size, product.size),
            const SizedBox(width: 40),
            _buildQuantityStepper(),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: AppColors.border),
        _buildExpandableSection(
          title: AppString.details,
          expanded: _detailsExpanded,
          onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
          content: product.description,
        ),
        const Divider(height: 1, color: AppColors.border),
        _buildExpandableSection(
          title: AppString.shippingReturns,
          expanded: _shippingExpanded,
          onTap: () => setState(() => _shippingExpanded = !_shippingExpanded),
          content:
              "Free standard shipping on orders over \$50. Unopened items can be returned within 30 days of delivery.",
        ),
      ],
    );
  }

  Widget _buildLabeledValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textGrey),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildQuantityStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.qty.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textGrey),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildStepperButton(Icons.remove, () {
              if (_quantity > 1) setState(() => _quantity--);
            }),
            SizedBox(
              width: 28,
              child: Text(
                "$_quantity",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
            ),
            _buildStepperButton(Icons.add, () => setState(() => _quantity++)),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade100),
        child: Icon(icon, size: 14, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required String content,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                Icon(expanded ? Icons.remove : Icons.add, size: 18, color: AppColors.textDark),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        InkWell(
          onTap: () => FavoritesService.instance.toggle(widget.product),
          customBorder: const CircleBorder(),
          child: Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ListenableBuilder(
              listenable: FavoritesService.instance,
              builder: (context, _) => SvgIcon(
                AppIcons.heart,
                color: FavoritesService.instance.isSaved(widget.product)
                    ? AppColors.accent
                    : AppColors.textGrey,
                size: 35,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                CartService.instance.addToCart(widget.product, quantity: _quantity);
                AppSnackBar.success(
                  context,
                  title: 'Added to bag',
                  message: '${widget.product.name} added to your bag',
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              icon: SvgIcon(AppIcons.bag, color: Colors.white, size: 18),
              label: const Text(
                AppString.addToBasket,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
