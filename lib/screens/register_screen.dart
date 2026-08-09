import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/services/auth_service.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Controllers to read text from the TextFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 2. Initialize the service and loading state
  final AuthService _authService = AuthService.instance;
  bool _isLoading = false;

  // 3. The function to handle the registration button press
  Future<void> _handleRegister() async {
    // Basic validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      AppSnackBar.error(context, title: 'Missing info', message: 'Please fill in all fields.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      AppSnackBar.error(context, title: 'Passwords don\'t match', message: 'Make sure both passwords are the same.');
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    // Call the API service
    final response = await _authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    // Stop loading
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // Handle the response
    if (response.status) {
      AppSnackBar.success(context, title: 'Account created', message: response.message);
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      AppSnackBar.error(context, title: 'Registration failed', message: response.message);
    }
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  color: Color.fromARGB(255, 231, 95, 118),
                ),
              ),

              const SizedBox(height: 40),

              // WELCOME TITLE
              const Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Sign up to continue your journey.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),

              const SizedBox(height: 32),

              // NAME FIELD
              TextField(
                controller: _nameController, // Attached controller
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

              const SizedBox(height: 16),

              // EMAIL FIELD
              TextField(
                controller: _emailController, // Attached controller
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: AppString.email,
                  prefixIcon: const Icon(Icons.email_outlined),
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
                obscureText: true,
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

              const SizedBox(height: 16),

              // CONFIRM PASSWORD FIELD
              TextField(
                controller: _confirmPasswordController, // Attached controller
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  prefixIcon: const Icon(Icons.key_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // Disable button while loading
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  // Show loading spinner or text based on state
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // LOGIN INSTEAD
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login instead? ",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: const Text(
                      "Login here",
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

              // OR SIGN UP WITH
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