import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/screens/address_screen.dart';
import 'package:skincare_app/screens/edit_profile_screen.dart';
import 'package:skincare_app/screens/help_support_screen.dart';
import 'package:skincare_app/screens/order_history_screen.dart';
import 'package:skincare_app/services/auth_service.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Placeholder text shown briefly while the real profile loads.
  String name = "";
  String email = "";
  String location = "Sterling, Brooklyn";
  String? avatarImagePath;
  int ordersCount = 0;
  int pointsBalance = 0;
  bool _isLoadingProfile = true;

  bool _isHireMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final response = await AuthService.instance.me();
    if (!mounted) return;

    if (!response.status || response.user == null) {
      // No/expired token, or the request failed outright (e.g. unreachable
      // backend) — either way there's no profile to show. Surface why
      // before redirecting, rather than silently bouncing to login.
      AppSnackBar.error(
        context,
        title: 'Session expired',
        message: response.message.isNotEmpty ? response.message : 'Please log in again.',
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    setState(() {
      name = response.user!.name;
      email = response.user!.email;
      pointsBalance = response.user!.pointsBalance;
      ordersCount = response.user!.ordersCount ?? 0;
      _isLoadingProfile = false;
    });
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<Map<String, String?>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(name: name, email: email, imagePath: avatarImagePath),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      name = result['name'] ?? name;
      email = result['email'] ?? email;
      avatarImagePath = result['imagePath'];
    });
  }

  Future<void> _openLocationEditor() async {
    final updated = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const AddressScreen()),
    );
    if (updated == null || updated.isEmpty || !mounted) return;
    setState(() => location = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header & Profile Card Stack
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Gradient Background Header
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFEBD8),
                        Color(0xFFFFF7F0),
                        AppColors.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacementNamed(context, '/home');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 22,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          const Text(
                            AppString.profileTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 22,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Profile Card Container
                Padding(
                  padding:
                      const EdgeInsets.only(top: 100, left: 20, right: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _isLoadingProfile
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                              )
                            : Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stats Section Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Orders', '$ordersCount',
                                Icons.shopping_bag_outlined, AppColors.accent),
                            _buildStatItem('Points', '$pointsBalance',
                                Icons.stars_rounded, Colors.amber),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Circle Avatar
                Positioned(
                  top: 55,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                      backgroundImage:
                          avatarImagePath != null ? FileImage(File(avatarImagePath!)) : null,
                      child: avatarImagePath == null
                          ? const Icon(Icons.person_outline_rounded,
                              size: 50, color: AppColors.accent)
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // General Options Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppString.generalSection,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTile(
                    icon: Icons.person_outline_rounded,
                    title: AppString.profileSetting,
                    onTap: _openEditProfile,
                  ),
                  _buildTile(
                    icon: Icons.location_on_outlined,
                    title: AppString.location,
                    onTap: _openLocationEditor,
                  ),
                  _buildTile(
                    icon: Icons.receipt_long_outlined,
                    title: AppString.orderHistory,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                    ),
                  ),
                  _buildTile(
                    icon: Icons.help_outline_rounded,
                    title: AppString.helpSupport,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                    ),
                  ),
                  _buildTile(
                    icon: Icons.logout_rounded,
                    title: AppString.logOut,
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    showChevron: false,
                    onTap: () => AuthService.logout(context),
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

  Widget _buildStatItem(
      String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppColors.textDark,
    Color textColor = AppColors.textDark,
    bool showChevron = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: iconColor),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                if (showChevron)
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}