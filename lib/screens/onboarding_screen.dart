import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Image takes the remaining space at the top,
            // so it shrinks/grows to fit any screen size (no overflow).
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/onborading5.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Title
            const Text(
              "An Evolving\ncollection of treatments",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'The Ordinary is born to disallow commodity to '
                'be disguised as ingenuity. The Ordinary is '
                '"Clinical formulations with integrity".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Page dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _Dot(active: false),
                _Dot(active: false),
                _Dot(active: true),
                _Dot(active: false),
              ],
            ),

            const SizedBox(height: 20),

            // Next button
            InkWell(
              onTap: () {
                // later: go to next page or home
                Navigator.pushReplacementNamed(context, "/login");
              },
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// One dot in the page indicator row.
class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 16,
      height: 3,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
