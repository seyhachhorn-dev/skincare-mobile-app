import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/address_model.dart';
import 'package:skincare_app/screens/address_screen.dart';
import 'package:skincare_app/screens/khqr_payment_screen.dart';
import 'package:skincare_app/screens/payment_pending_screen.dart';
import 'package:skincare_app/screens/thank_you_screen.dart';
import 'package:skincare_app/services/address_service.dart';
import 'package:skincare_app/services/cart_service.dart';
import 'package:skincare_app/services/order_service.dart';
import 'package:skincare_app/services/stripe_checkout_service.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const List<String> _paymentMethods = ['card', 'bakong_khqr'];
  static const List<String> _shippingMethods = ['dhl', 'inpost'];

  int _selectedPayment = 1; // 0 = Card (Stripe), 1 = Bakong KHQR
  int _selectedShipping = 1; // 0 = DHL, 1 = InPost

  Address? _address;
  bool _isLoadingAddress = true;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final response = await AddressService.instance.list();
    if (!mounted) return;

    Address? picked;
    if (response.status && response.addresses.isNotEmpty) {
      picked = response.addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => response.addresses.first,
      );
    }
    setState(() {
      _address = picked;
      _isLoadingAddress = false;
    });
  }

  Future<void> _editAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressScreen()),
    );
    if (!mounted) return;
    setState(() => _isLoadingAddress = true);
    _loadAddress();
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;

    if (_address == null) {
      AppSnackBar.error(
        context,
        title: 'No address yet',
        message: 'Add a shipping address before placing an order.',
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    if (_paymentMethods[_selectedPayment] == 'card') {
      await _payByCard();
      return;
    }

    final response = await OrderService.instance.placeOrder(
      addressId: _address!.id,
      paymentMethod: _paymentMethods[_selectedPayment],
      shippingMethod: _shippingMethods[_selectedShipping],
    );
    if (!mounted) return;

    if (!response.status || response.order == null) {
      setState(() => _isPlacingOrder = false);
      AppSnackBar.error(
        context,
        title: "Couldn't place order",
        message: response.message.isNotEmpty
            ? response.message
            : 'Please try again.',
      );
      return;
    }

    // The server already emptied the cart as part of placing the order —
    // mirror that locally instead of another round trip.
    CartService.instance.clear();

    final order = response.order!;
    final isBakongKhqr = _paymentMethods[_selectedPayment] == 'bakong_khqr';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isBakongKhqr
            ? KhqrPaymentScreen(order: order)
            : ThankYouScreen(order: order),
      ),
    );
  }

  Future<void> _payByCard() async {
    final response = await StripeCheckoutService.instance.pay(
      addressId: _address!.id,
      shippingMethod: _shippingMethods[_selectedShipping],
    );
    if (!mounted) return;

    if (!response.status || response.checkout == null) {
      setState(() => _isPlacingOrder = false);
      await CartService.instance.load();
      if (!mounted) return;
      AppSnackBar.error(
        context,
        title: "Couldn't complete card payment",
        message: response.message,
      );
      return;
    }

    CartService.instance.clear();
    final checkout = response.checkout!;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPendingScreen(
          orderNumber: checkout.orderNumber,
          amount: checkout.amount,
          currency: checkout.currency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      AppString.shippingInformation,
                      AppString.edit,
                      onAction: _editAddress,
                    ),
                    const SizedBox(height: 10),
                    _buildAddressCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      AppString.paymentMethod,
                      AppString.addACard,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      index: 0,
                      icon: Icons.credit_card_outlined,
                      label: AppString.addACard,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      index: 1,
                      icon: Icons.qr_code_2,
                      label: AppString.bakongKhqr,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      AppString.shippingMethod,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildShippingOption(
                      index: 0,
                      carrier: "DHL",
                      estimate: "Estimated delivery: 5-7 business days",
                    ),
                    const SizedBox(height: 10),
                    _buildShippingOption(
                      index: 1,
                      carrier: "InPost",
                      estimate: "Estimated delivery: 3-4 business days",
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppString.checkoutNote,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildPlaceOrderButton(),
          ],
        ),
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
              AppString.checkoutTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String action, {
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
        ),
      ],
    );
  }

  // ---------- ADDRESS CARD ----------
  Widget _buildAddressCard() {
    if (_isLoadingAddress) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final address = _address;
    return GestureDetector(
      onTap: _editAddress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.textDark),
            const SizedBox(width: 12),
            Expanded(
              child: address == null
                  ? const Text(
                      "No address yet — tap to add one",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.type.isEmpty
                              ? "Address"
                              : "${address.type[0].toUpperCase()}${address.type.substring(1)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.formatted,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  // ---------- PAYMENT OPTION ----------
  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedPayment == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.textDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            _buildRadio(isSelected),
          ],
        ),
      ),
    );
  }

  // ---------- SHIPPING OPTION ----------
  Widget _buildShippingOption({
    required int index,
    required String carrier,
    required String estimate,
  }) {
    final isSelected = _selectedShipping == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedShipping = index),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadio(isSelected),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carrier,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  estimate,
                  style: const TextStyle(
                    fontSize: 12,
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

  Widget _buildRadio(bool isSelected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.border,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
              ),
            )
          : null,
    );
  }

  // ---------- PLACE ORDER ----------
  Widget _buildPlaceOrderButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isPlacingOrder ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: _isPlacingOrder
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  AppString.placeAnOrder,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
