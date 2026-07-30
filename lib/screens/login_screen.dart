import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [

              const SizedBox(height: 40),

              // BRAND NAME
              const Text(
                AppString.brandName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 40),

              // WELCOME TITLE
              const Text(
                AppString.welcome,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                AppString.welcomeSub,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),

              const SizedBox(height: 32),

              // EMAIL FIELD
              TextField(
                decoration: InputDecoration(
                  hintText: AppString.email,
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // PASSWORD FIELD
              TextField(
                obscureText: true, // hides the password
                decoration: InputDecoration(
                  hintText: AppString.password,
                  prefixIcon: const Icon(Icons.key_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // FORGOT PASSWORD
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    AppString.forgotPass,
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // SIGN IN BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // later: call login API
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    AppString.signIn,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CREATE ONE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppString.noAccount,
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      AppString.createOne,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // OR SIGN IN WITH
              const Text(
                AppString.orSignIn,
                style: TextStyle(color: AppColors.textGrey),
              ),

              const SizedBox(height: 20),

              // SOCIAL ICONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SocialCircle(icon: Icons.g_mobiledata),
                  SizedBox(width: 20),
                  _SocialCircle(icon: Icons.apple),
                  SizedBox(width: 20),
                  _SocialCircle(icon: Icons.facebook),
                ],
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}

// Small reusable widget for one social login circle
class _SocialCircle extends StatelessWidget {
  final IconData icon;
  const _SocialCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 28),
    );
  }
}