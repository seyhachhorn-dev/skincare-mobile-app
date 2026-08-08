import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/screens/thank_you_screen.dart';
import 'package:skincare_app/services/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0; // 0 = Apple Pay, 1 = PayPal
  int _selectedShipping = 1; // 0 = DHL, 1 = InPost

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
                    _buildSectionHeader(AppString.shippingInformation, AppString.edit),
                    const SizedBox(height: 10),
                    _buildAddressCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(AppString.paymentMethod, AppString.addACard),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      index: 0,
                      icon: Icons.apple,
                      label: "Apple Pay",
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      index: 1,
                      icon: Icons.account_balance_wallet_outlined,
                      label: "PayPal",
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      AppString.shippingMethod,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
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
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text(action, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
      ],
    );
  }

  // ---------- ADDRESS CARD ----------
  Widget _buildAddressCard() {
    return Container(
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Work", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                SizedBox(height: 4),
                Text(
                  "357 Maple Street, Apartment 2B, New York, NY 10013",
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
                ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
        ],
      ),
    );
  }

  // ---------- PAYMENT OPTION ----------
  Widget _buildPaymentOption({required int index, required IconData icon, required String label}) {
    final isSelected = _selectedPayment == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 20, color: AppColors.textDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ),
            _buildRadio(isSelected),
          ],
        ),
      ),
    );
  }

  // ---------- SHIPPING OPTION ----------
  Widget _buildShippingOption({required int index, required String carrier, required String estimate}) {
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
                Text(carrier, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(estimate, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
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
        border: Border.all(color: isSelected ? AppColors.accent : AppColors.border, width: 2),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
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
          onPressed: () {
            final points = CartService.instance.pointsEarned;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ThankYouScreen(pointsEarned: points)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          child: const Text(
            AppString.placeAnOrder,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
