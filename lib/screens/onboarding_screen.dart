import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed background photo.
          Image.asset(
            'assets/images/onboardscreen-img.png',
            fit: BoxFit.cover,
          ),

          // Soft scrim so text stays legible over the photo.
          Container(
            decoration: BoxDecoration(
              
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildBrandMark(),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 10),
                _buildSubtitle(),
                const Spacer(),
                _buildBottomControls(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- BRAND MARK ----------
  Widget _buildBrandMark() {
    return Text(
      AppString.brandName,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        color: AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ---------- TITLE ----------
  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        AppString.skinQuizTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          height: 1.3,
        ),
      ),
    );
  }

  // ---------- SUBTITLE ----------
  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        AppString.skinQuizSubtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Color.fromARGB(255, 50, 50, 50),
          height: 1.5,
        ),
      ),
    );
  }

  // ---------- BOTTOM CONTROLS (Back / dots / next) ----------
  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBackButton(context),
          _buildPageDots(),
          _buildNextButton(context),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child: const Text(
        AppString.back,
        style: TextStyle(fontWeight: FontWeight.w600, shadows: [
          Shadow(color: Colors.black38, blurRadius: 6),
        ]),
      ),
    );
  }

  Widget _buildPageDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _Dot(active: false),
        _Dot(active: true),
        _Dot(active: false),
        _Dot(active: false),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushReplacementNamed(context, "/login"),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: const Icon(Icons.arrow_forward, color: AppColors.textDark),
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
      width: active ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
