import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/cart_item.dart';
import 'package:skincare_app/screens/checkout_screen.dart';
import 'package:skincare_app/services/cart_service.dart';
import 'package:skincare_app/widgets/app_bottom_nav.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int currentTab = 3; // Bag tab active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListenableBuilder(
                listenable: CartService.instance,
                builder: (context, _) {
                  final items = CartService.instance.items;
                  if (items.isEmpty) return _buildEmptyState();
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: items.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 24, color: AppColors.border),
                          itemBuilder: (context, index) => _buildCartRow(items[index]),
                        ),
                      ),
                      _buildCouponField(),
                      const SizedBox(height: 16),
                      _buildTotalAndCheckout(items),
                    ],
                  );
                },
              ),
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
          } else if (index == 1) {
            Navigator.pushNamed(context, '/explore');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/saved');
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
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          const Expanded(
            child: Text(
              AppString.shoppingCart,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ---------- EMPTY STATE ----------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              AppString.emptyCart,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              AppString.emptyCartSub,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- CART ROW (swipe left to delete) ----------
  Widget _buildCartRow(CartItem item) {
    return Dismissible(
      key: ValueKey(item),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => CartService.instance.removeItem(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(item.product.image, width: 64, height: 64, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => CartService.instance.removeItem(item),
                      child: const Icon(Icons.close, size: 18, color: AppColors.textGrey),
                    ),
                  ],
                ),
                if (item.product.size.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.product.size, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${item.product.price}.00 USD",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    _buildQtyStepper(item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyStepper(CartItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => CartService.instance.decrement(item),
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.remove, size: 14, color: AppColors.textDark),
            ),
          ),
          SizedBox(
            width: 22,
            child: Text(
              "${item.quantity}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          InkWell(
            onTap: () => CartService.instance.increment(item),
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.add, size: 14, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COUPON FIELD ----------
  Widget _buildCouponField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppString.addCouponCode,
          prefixIcon: const Icon(Icons.confirmation_number_outlined, color: AppColors.textGrey),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------- TOTAL + CHECKOUT ----------
  Widget _buildTotalAndCheckout(List<CartItem> items) {
    final subtotal = CartService.instance.subtotal;
    final points = CartService.instance.pointsEarned;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppString.total,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Order and get $points points",
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$$subtotal.00 USD",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    AppString.freeShipping,
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: const Text(
                AppString.proceedToCheckout,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
