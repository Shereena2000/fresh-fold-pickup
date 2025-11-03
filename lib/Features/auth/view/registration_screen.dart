import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Features/auth/common/widgets/heading_section.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_text_feild.dart';
import 'package:fresh_fold_pickup/Settings/constants/sized_box.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:provider/provider.dart';

import '../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../Settings/utils/p_pages.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../view_model.dart/auth_view_model.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pre-fill form with existing driver data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      
      // If driver data exists, pre-fill all controllers
      if (authViewModel.currentVendor != null) {
        final driver = authViewModel.currentVendor!;
        
        // Pre-fill readonly fields (Full Name and Email)
        if (driver.fullName != null && driver.fullName!.isNotEmpty) {
          authViewModel.usernameController.text = driver.fullName!;
        }
        if (driver.email != null && driver.email!.isNotEmpty) {
          authViewModel.emailController.text = driver.email!;
        }
        
        // Pre-fill editable fields (only if controller is empty)
        if (authViewModel.phoneController.text.isEmpty && driver.phoneNumber != null) {
          authViewModel.phoneController.text = driver.phoneNumber!;
        }
        if (authViewModel.locationController.text.isEmpty && driver.location != null) {
          authViewModel.locationController.text = driver.location!;
        }
        if (authViewModel.vehicleTypeController.text.isEmpty && driver.vehicleType != null) {
          authViewModel.vehicleTypeController.text = driver.vehicleType!;
        }
        if (authViewModel.vehicleNumberController.text.isEmpty && driver.vehicleNumber != null) {
          authViewModel.vehicleNumberController.text = driver.vehicleNumber!;
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AuthViewModel>(
            builder: (context, viewModel, child) {
              final isEditMode = viewModel.currentVendor != null && 
                                 viewModel.currentVendor!.phoneNumber != null;
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizeBoxH(15),
                    HeadingSection(title: isEditMode ? "Edit Profile" : "Driver Registration"),
                    SizeBoxH(15),
                    
                    Text(
                      isEditMode 
                          ? 'Update your driver profile' 
                          : 'Complete your driver profile',
                      style: PTextStyles.bodyMedium.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizeBoxH(25),
                    
                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PColors.primaryColor.withOpacity(0.1),
                              border: Border.all(
                                color: PColors.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: _buildProfileImage(viewModel),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: viewModel.isUploadingImage 
                                  ? null 
                                  : () => _handleImageUpload(context, viewModel),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: viewModel.isUploadingImage 
                                      ? Colors.grey 
                                      : PColors.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: viewModel.isUploadingImage
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizeBoxH(24),
                    
                    // Full Name (readonly - set during signup)
                    CustomTextFeild(
                      prefixfn: () {},
                      prefixIcon: Icon(Icons.person),
                      hintText: "Full Name",
                      textHead: "Full Name (Cannot be changed)",
                      readOnly: true,
                      controller: viewModel.usernameController,
                    ),
                    SizeBoxH(18),
                    
                    // Email (readonly - set during signup)
                    CustomTextFeild(
                      prefixfn: () {},
                      prefixIcon: Icon(Icons.email),
                      hintText: "Email",
                      textHead: "Email (Cannot be changed)",
                      readOnly: true,
                      controller: viewModel.emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizeBoxH(18),
                    
                    // Phone Number (editable)
                    CustomTextFeild(
                      prefixfn: () {},
                      prefixIcon: Icon(Icons.phone),
                      hintText: "Phone Number",
                      textHead: "Phone Number *",
                      controller: viewModel.phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    SizeBoxH(18),
                    
                    // Location (editable)
                    CustomTextFeild(
                      prefixfn: () {},
                      prefixIcon: Icon(Icons.location_on),
                      hintText: "Location / Address",
                      textHead: "Location *",
                      controller: viewModel.locationController,
                    ),
                    SizeBoxH(18),
                    
                    // Vehicle Type (Optional)
                    CustomTextFeild(
                      prefixfn: () {},
                      prefixIcon: Icon(Icons.directions_bike),
                      hintText: "Vehicle Type (e.g., Bike, Car)",
                      textHead: "Vehicle Type (Optional)",
                      controller: viewModel.vehicleTypeController,
                    ),
                    SizeBoxH(18),
                    
                    // Vehicle Number (Optional)
                    CustomTextFeild(
                      prefixfn: () {},
                      prefixIcon: Icon(Icons.pin),
                      hintText: "Vehicle Number (e.g., ABC-1234)",
                      textHead: "Vehicle Number (Optional)",
                      controller: viewModel.vehicleNumberController,
                    ),
                    
                    if (viewModel.errorMessage != null) ...[
                      SizeBoxH(16),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          viewModel.errorMessage!,
                          style: PTextStyles.bodySmall.copyWith(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    
                    SizeBoxH(30),
                    
                    viewModel.isLoading
                        ? CircularProgressIndicator()
                        : CustomElavatedTextButton(
                            onPressed: () async {
                              viewModel.clearError();
                              bool success = await viewModel.registerUser();
                              
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEditMode 
                                          ? 'Profile updated successfully!' 
                                          : 'Registration completed successfully!',
                                    ),
                                    backgroundColor: PColors.successGreen,
                                  ),
                                );
                                
                                // Navigate based on mode
                                if (isEditMode) {
                                  // Edit mode - just go back to profile
                                  Navigator.pop(context);
                                } else {
                                  // Registration mode - navigate to home
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    PPages.wrapperPageUi,
                                    (route) => false,
                                  );
                                }
                              }
                            },
                            text: isEditMode ? 'Save Changes' : 'Complete Registration',
                          ),
                          
                    SizeBoxH(20),
                    
                    // Optional: Skip/Cancel button
                    TextButton(
                      onPressed: () {
                        if (isEditMode) {
                          // Edit mode - just go back
                          Navigator.pop(context);
                        } else {
                          // Registration mode - skip for now
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            PPages.wrapperPageUi,
                            (route) => false,
                          );
                        }
                      },
                      child: Text(
                        isEditMode ? 'Cancel' : 'Skip for now',
                        style: PTextStyles.bodyMedium.copyWith(
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build profile image widget
  Widget _buildProfileImage(AuthViewModel viewModel) {
    // Show selected local image
    if (viewModel.selectedImagePath != null) {
      return Image.file(
        File(viewModel.selectedImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: 60,
            color: PColors.primaryColor,
          );
        },
      );
    }

    // Show network image from Firebase
    if (viewModel.currentVendor?.profileImageUrl != null &&
        viewModel.currentVendor!.profileImageUrl!.isNotEmpty) {
      return Image.network(
        viewModel.currentVendor!.profileImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: PColors.primaryColor,
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
      );
    }

    // Default icon
    return Icon(
      Icons.person,
      size: 60,
      color: PColors.primaryColor,
    );
  }

  /// Handle image upload process
  Future<void> _handleImageUpload(BuildContext context, AuthViewModel viewModel) async {
    // Show source selection
    await viewModel.selectImageSource(context);

    // If image was selected, upload it
    if (viewModel.selectedImagePath != null && context.mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Upload Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PColors.primaryColor, width: 2),
                ),
                child: ClipOval(
                  child: Image.file(
                    File(viewModel.selectedImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text('Do you want to upload this photo as your profile picture?'),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.clearSelectedImage();
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: PColors.primaryColor,
              ),
              child: Text('Upload', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final success = await viewModel.uploadProfileImage();

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile photo uploaded successfully!'),
                backgroundColor: PColors.successGreen,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.errorMessage ?? 'Failed to upload photo'),
                backgroundColor: PColors.errorRed,
              ),
            );
          }
        }
      }
    }
  }
}


