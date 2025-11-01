import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Static profile data
    final driverName = 'John Driver';
    final driverId = 'DRV-12345';
    final phoneNumber = '+91 98765 43210';
    final email = 'john.driver@laundryapp.com';
    final joinedDate = '15 Jan 2024';
    final totalDeliveries = 1245;
    final rating = 4.8;

    return Scaffold(
      appBar: CustomAppBar(title: 'Profile'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [PColors.primaryColor, PColors.secondoryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: PColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    driverName,
                    style: PTextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Driver ID: $driverId',
                    style: PTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Rating
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 6),
                        Text(
                          rating.toString(),
                          style: PTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Stats Card
            _buildStatCard(
              'Total Deliveries',
              totalDeliveries.toString(),
              Icons.local_shipping,
            ),
            SizedBox(height: 20),
            // Personal Information
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: PTextStyles.displaySmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: PColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow(Icons.phone, 'Phone', phoneNumber),
                  SizedBox(height: 12),
                  Divider(color: PColors.lightGray),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.email, 'Email', email),
                  SizedBox(height: 12),
                  Divider(color: PColors.lightGray),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.calendar_today, 'Joined Date', joinedDate),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Settings Options
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
                  _buildMenuOption(Icons.notifications, 'Notifications', () {}),
                  Divider(color: PColors.lightGray),
                  _buildMenuOption(Icons.language, 'Language', () {}),
                  Divider(color: PColors.lightGray),
                  _buildMenuOption(Icons.help_outline, 'Help & Support', () {}),
                  Divider(color: PColors.lightGray),
                  _buildMenuOption(Icons.info_outline, 'About', () {}),
                  Divider(color: PColors.lightGray),
                  _buildMenuOption(
                    Icons.logout,
                    'Logout',
                    () {},
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
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
          Icon(icon, color: PColors.primaryColor, size: 32),
          SizedBox(height: 12),
          Text(
            value,
            style: PTextStyles.displaySmall.copyWith(
              color: PColors.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: PTextStyles.bodySmall.copyWith(
              color: PColors.darkGray.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: PColors.primaryColor, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: PTextStyles.bodySmall.copyWith(
                  color: PColors.darkGray.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: PTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
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
            ),
          ],
        ),
      ),
    );
  }
}
