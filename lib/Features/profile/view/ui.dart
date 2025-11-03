import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_pages.dart';
import 'package:provider/provider.dart';
import '../../auth/view_model.dart/auth_view_model.dart';
import '../../delivery/view_model/delivery_view_model.dart';
import '../view_model/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Profile'),
      body: Consumer2<AuthViewModel, ProfileViewModel>(
        builder: (context, authViewModel, profileViewModel, child) {
          // Update ProfileViewModel whenever AuthViewModel changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authViewModel.currentVendor != null) {
              profileViewModel.setDriverData(authViewModel.currentVendor);
              
              // Set delivery view model if not already set
              final deliveryViewModel = context.read<DeliveryViewModel>();
              profileViewModel.setDeliveryViewModel(deliveryViewModel);
            }
          });
          
          final viewModel = profileViewModel;
          return SingleChildScrollView(
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
                      child: viewModel.profileImageUrl != null && viewModel.profileImageUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                viewModel.profileImageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: PColors.primaryColor,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 60,
                                    color: PColors.primaryColor,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: PColors.primaryColor,
                            ),
                    ),
                      SizedBox(height: 16),
                      Text(
                        viewModel.driverName,
                        style: PTextStyles.displaySmall.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Driver ID: ${viewModel.driverId.substring(0, viewModel.driverId.length > 8 ? 8 : viewModel.driverId.length).toUpperCase()}',
                        style: PTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Deliveries',
                        viewModel.totalDeliveries.toString(),
                        Icons.local_shipping,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Active',
                        viewModel.activeDeliveries.toString(),
                        Icons.pending_actions,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        viewModel.completedDeliveries.toString(),
                        Icons.check_circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Profile',
                        '${viewModel.profileCompletionPercentage.toInt()}%',
                        Icons.account_circle,
                      ),
                    ),
                  ],
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
                      _buildInfoRow(Icons.phone, 'Phone', viewModel.phoneNumber),
                      SizedBox(height: 12),
                      Divider(color: PColors.lightGray),
                      SizedBox(height: 12),
                      _buildInfoRow(Icons.email, 'Email', viewModel.email),
                      SizedBox(height: 12),
                      Divider(color: PColors.lightGray),
                      SizedBox(height: 12),
                      _buildInfoRow(Icons.location_on, 'Location', viewModel.location),
                      SizedBox(height: 12),
                      Divider(color: PColors.lightGray),
                      SizedBox(height: 12),
                      _buildInfoRow(Icons.calendar_today, 'Joined Date', viewModel.joinedDate),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Vehicle Information (if available)
                if (viewModel.vehicleType != 'Not specified')
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
                          'Vehicle Information',
                          style: PTextStyles.displaySmall.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: PColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow(Icons.directions_bike, 'Vehicle Type', viewModel.vehicleType),
                        SizedBox(height: 12),
                        Divider(color: PColors.lightGray),
                        SizedBox(height: 12),
                        _buildInfoRow(Icons.pin, 'Vehicle Number', viewModel.vehicleNumber),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                // Edit Profile Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, PPages.registration);
                    },
                    icon: Icon(Icons.edit, color: Colors.white),
                    label: Text(
                      'Edit Profile',
                      style: PTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          );
        },
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

}
