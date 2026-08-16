import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/order.dart';
import 'package:skincare_app/utils/money.dart';

class ThankYouScreen extends StatefulWidget {
  final Order order;
  const ThankYouScreen({super.key, required this.order});

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.spa_outlined,
                size: 28,
                color: AppColors.textDark,
              ),
              const Spacer(),
              _buildCheckBadge(),
              const SizedBox(height: 28),
              const Text(
                AppString.thankYouTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your order #${widget.order.orderNumber} is confirmed and in processing.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "You have earned ${widget.order.pointsEarned} points!",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Spacer(),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: AppString.needAssistance),
                    TextSpan(
                      text: AppString.support,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildOrderDetailsButton(),
              const SizedBox(height: 12),
              _buildDoneButton(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- SUCCESS CHECKMARK WITH GLOW RINGS ----------
  Widget _buildCheckBadge() {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.14),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 2.5),
            ),
            child: const Icon(Icons.check, color: AppColors.success, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text("Order #${widget.order.orderNumber}"),
            content: Text(
              "${widget.order.itemCount} item${widget.order.itemCount == 1 ? '' : 's'} · "
              "${Money.usd(widget.order.total)}\nYou earned ${widget.order.pointsEarned} points on this order.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Text(
          AppString.orderDetailsBtn,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Text(
          AppString.doneBtn,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
