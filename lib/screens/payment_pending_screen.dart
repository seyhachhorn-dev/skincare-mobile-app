import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/screens/order_history_screen.dart';
import 'package:skincare_app/utils/money.dart';

/// Shown after PaymentSheet completes. A Stripe webhook, not this screen,
/// determines whether the order is paid and ready for fulfillment.
class PaymentPendingScreen extends StatelessWidget {
  final String orderNumber;
  final int amount;
  final String currency;

  const PaymentPendingScreen({
    super.key,
    required this.orderNumber,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                size: 72,
                color: AppColors.accent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment submitted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We are confirming your payment securely. Your order will move to processing once Stripe confirms it.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'Order #$orderNumber',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currency.toLowerCase() == 'usd'
                          ? Money.usdCents(amount)
                          : '${currency.toUpperCase()} ${(amount / 100).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryScreen(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text('View order history'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
