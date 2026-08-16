import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/services/auth_service.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controllers to read text from the TextFields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Initialize the service and loading state
  // (Make sure you initialize this the exact same way that fixed your earlier error)
  final AuthService _authService = AuthService.instance;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // 3. The function to handle the login button press
  Future<void> _handleLogin() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AppSnackBar.error(context, title: 'Missing info', message: 'Please enter your email and password.');
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    // Call the API service
    final response = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // Stop loading
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // Handle the response. AuthService already persisted the token to
    // SharedPreferences internally on success, before returning here.
    if (response.status) {
      AppSnackBar.success(context, title: 'Welcome back!', message: response.message);
      Navigator.pushReplacementNamed(context, "/favorite");
    } else {
      AppSnackBar.error(context, title: 'Login failed', message: response.message);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

              // EMAIL FIELD
              TextField(
                controller: _emailController, // Attached controller
                keyboardType: TextInputType.emailAddress,
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
                controller: _passwordController, // Attached controller
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: AppString.password,
                  prefixIcon: const Icon(Icons.key_outlined),
                  suffixIcon: IconButton(
                    tooltip: _isPasswordVisible
                        ? 'Hide password'
                        : 'Show password',
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textGrey,
                    ),
                  ),
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
                  onPressed: _isLoading ? null : _handleLogin, // Disable while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
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
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/register");
                    },
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
