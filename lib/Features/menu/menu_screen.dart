import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Features/auth/view_model.dart/auth_view_model.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_pages.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Menu'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Settings Options Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PColors.lightGray, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuOption(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () {
                      Navigator.pushNamed(context, PPages.privacyPolicy);
                    },
                  ),
                  Divider(color: PColors.lightGray),
                  _buildMenuOption(
                    context,
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pushNamed(context, PPages.helpSupport);
                    },
                  ),
                  Divider(color: PColors.lightGray),
                  _buildMenuOption(
                    context,
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () {
                      Navigator.pushNamed(context, PPages.about);
                    },
                  ),
                  Divider(color: PColors.lightGray),
                  _buildMenuOption(
                    context,
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () => _handleLogout(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // App Version
            Text(
              'Version 1.0.0',
              style: PTextStyles.bodySmall.copyWith(
                color: PColors.darkGray.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? PColors.errorRed : PColors.primaryColor,
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: PTextStyles.bodyMedium.copyWith(
                  color: isDestructive ? PColors.errorRed : PColors.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: PColors.darkGray.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: PTextStyles.displaySmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: PTextStyles.bodyMedium,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: PColors.darkGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    color: PColors.primaryColor,
                  ),
                ),
              );
              
              // Sign out
              final authViewModel = context.read<AuthViewModel>();
              final success = await authViewModel.signOut();
              
              // Close loading
              if (context.mounted) {
                Navigator.pop(context);
              }
              
              // Navigate to login
              if (context.mounted) {
                if (success) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    PPages.login,
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to logout. Please try again.'),
                      backgroundColor: PColors.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}

