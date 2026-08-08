import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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

              // Name FIELD
              TextField(
                decoration: InputDecoration(
                  hintText: AppString.name,
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

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

              // SIGN IN BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // later: call register API
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

              // OR SIGN Up WITH
              const Text(
                "Or sign up with",
                style: TextStyle(color: AppColors.textGrey),
              ),

              const SizedBox(height: 10),

              // SOCIAL ICONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SocialCircle('assets/icons/google.png'),
                  SizedBox(width: 20),
                  _SocialCircle('assets/icons/facebook.png'),
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
  final String imagePath;

  const _SocialCircle(this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(imagePath),
      ),
    );
  }
}