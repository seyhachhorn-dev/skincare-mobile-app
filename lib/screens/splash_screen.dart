import 'dart:async';
import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
  );

  late final Animation<double> _logoScale = Tween(begin: 0.82, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
  );

  late final Animation<Offset> _textSlide = Tween(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.35, 1.0, curve: Curves.easeOut)));

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.splashGradient,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft decorative color blobs for depth, like a premium ecommerce splash.
            Positioned(
              top: -size.width * 0.28,
              right: -size.width * 0.32,
              child: _Blob(
                diameter: size.width * 0.8,
                color: AppColors.primaryLight.withValues(alpha: 0.28),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.32,
              left: -size.width * 0.3,
              child: _Blob(
                diameter: size.width * 0.85,
                color: AppColors.primary.withValues(alpha: 0.16),
              ),
            ),

            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 32,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/hana-no-background.png',
                          width: 108,
                          height: 108,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          Text(
                            AppString.brandName,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48),
                            child: Text(
                              AppString.tagline,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textGrey,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  FadeTransition(
                    opacity: _textFade,
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.primary,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double diameter;
  final Color color;

  const _Blob({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
