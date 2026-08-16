import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/screens/about_screen.dart';
import 'package:skincare_app/screens/settings_screen.dart';
import 'package:skincare_app/services/auth_service.dart';

/// Shared, neutral navigation drawer for the store screens.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Drawer(
      width: screenWidth > 400 ? 320 : screenWidth * 0.84,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.settings_outlined,
              title: AppString.menuSettings,
              onTap: () => _openPage(context, const SettingsScreen()),
            ),
            _buildMenuTile(
              icon: Icons.info_outline_rounded,
              title: AppString.menuAbout,
              onTap: () => _openPage(context, const AboutScreen()),
            ),
            const Spacer(),
            const Divider(height: 1, color: AppColors.border),
            _buildMenuTile(
              icon: Icons.logout_rounded,
              title: AppString.logOut,
              isDestructive: true,
              showChevron: false,
              onTap: () => AuthService.logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Image.asset(
              'assets/images/hana-no-background.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.brandName,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Beauty and skincare',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close menu',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showChevron = true,
  }) {
    final foregroundColor = isDestructive ? AppColors.error : AppColors.textDark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      minLeadingWidth: 30,
      leading: Icon(icon, color: foregroundColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: foregroundColor,
        ),
      ),
      trailing: showChevron
          ? const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textGrey,
            )
          : null,
      onTap: onTap,
    );
  }

  void _openPage(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }
}
