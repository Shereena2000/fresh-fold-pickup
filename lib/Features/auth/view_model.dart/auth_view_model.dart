import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/vendor_model.dart';
import '../repositories/auth_repositories.dart';
import '../../../Settings/services/cloudinary_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
  PickUpModel? _currentVendor;
  PickUpModel? get currentVendor => _currentVendor;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  
  // Registration screen controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  
  // Image upload
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  String? _selectedImagePath;
  String? get selectedImagePath => _selectedImagePath;
  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  String? _errorMessage;
  String? get error => _errorMessage;
  String? get errorMessage => _errorMessage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  //sigin - Load from drivers/ collection
  Future<bool> signIn() async {
    if (emailController.text.isEmpty) {
      _errorMessage = 'Please enter your email';
      notifyListeners();
      return false;
    }

    if (passwordController.text.isEmpty) {
      _errorMessage = 'Please enter your password';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Load driver data after successful login (from drivers/ collection)
      await loadDriverData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Check if driver profile is complete
  bool get isDriverProfileComplete {
    return _currentVendor != null &&
        _currentVendor!.phoneNumber != null &&
        _currentVendor!.phoneNumber!.isNotEmpty &&
        _currentVendor!.location != null &&
        _currentVendor!.location!.isNotEmpty;
  }

  //signup
  Future<bool> signUp() async {
    // Validate username
    if (usernameController.text.isEmpty) {
      _errorMessage = 'Please enter a username';
      notifyListeners();
      return false;
    }

    // Validate email
    if (emailController.text.isEmpty) {
      _errorMessage = 'Please enter your email';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(emailController.text)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    // Validate password
    if (passwordController.text.isEmpty) {
      _errorMessage = 'Please enter a password';
      notifyListeners();
      return false;
    }

    if (passwordController.text.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    // Validate confirm password
    if (confirmPasswordController.text.isEmpty) {
      _errorMessage = 'Please confirm your password';
      notifyListeners();
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _errorMessage = 'Passwords donot match';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create user account
      UserCredential userCredential = await _repository.signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      String uid = userCredential.user!.uid;

      // Save user data to Firestore
      await _repository.registerUserWithEmail(
        uid: uid,
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
      );

      // Send verification email
      await _repository.sendEmailVerification();

      // Load user data
      //  await loadUserData(uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current user
  Future<bool> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signOut();
      
      // Clear all data after successful logout
      clearLoginData();
      clearSignupData();
      _currentVendor = null; // Clear vendor/driver data
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check if user is currently signed in
  bool isUserSignedIn() {
    return _repository.isUserSignedIn();
  }

  /// Get current user
  User? getCurrentUser() {
    return _repository.getCurrentUser();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearLoginData() {
    emailController.clear();
    passwordController.clear();
    _errorMessage = null;
    _isPasswordVisible = false;
    notifyListeners();
  }

  /// Clear signup-specific data
  void clearSignupData() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _errorMessage = null;
    _isPasswordVisible = false;
    _isConfirmPasswordVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    locationController.dispose();
    vehicleTypeController.dispose();
    vehicleNumberController.dispose();
    super.dispose();
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      _errorMessage = 'Please enter your email address';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Load driver data from Firebase (from drivers/ collection)
  Future<void> loadDriverData() async {
    User? user = getCurrentUser();
    if (user == null) return;

    try {
      _currentVendor = await _repository.getDriverData(user.uid);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Stream driver data for real-time updates
  Stream<PickUpModel?> streamDriverData() {
    User? user = getCurrentUser();
    if (user == null) {
      return Stream.value(null);
    }
    return _repository.streamDriverData(user.uid);
  }
  
  /// Load vendor data from Firebase
  Future<void> loadVendorData() async {
    User? user = getCurrentUser();
    if (user == null) return;

    try {
      _currentVendor = await _repository.getVendorData(user.uid);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Stream vendor data for real-time updates
  Stream<PickUpModel?> streamVendorData() {
    User? user = getCurrentUser();
    if (user == null) {
      return Stream.value(null);
    }
    return _repository.streamVendorData(user.uid);
  }
  
  /// Register user with additional profile details (from Registration Screen)
/// Register user with additional profile details (from Registration Screen)
Future<bool> registerUser() async {
  // Validate phone number
  if (phoneController.text.isEmpty) {
    _errorMessage = 'Please enter your phone number';
    notifyListeners();
    return false;
  }

  // Validate location
  if (locationController.text.isEmpty) {
    _errorMessage = 'Please enter your location';
    notifyListeners();
    return false;
  }

  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

    try {
      User? user = getCurrentUser();
      if (user == null) {
        throw Exception('User not found. Please sign up again.');
      }

      debugPrint('════════════════════════════════════════');
      debugPrint('🔹 REGISTER USER - Starting...');
      debugPrint('════════════════════════════════════════');

      // If _currentVendor is null, load it once
      if (_currentVendor == null) {
        debugPrint('   ⚠️ _currentVendor is null, loading from Firebase...');
        await loadDriverData();
      }
      
      // STEP 1: Check if user selected a new image
      String? finalProfileImageUrl = _currentVendor?.profileImageUrl;
      
      if (_selectedImagePath != null) {
        debugPrint('   📸 New image selected, uploading to Cloudinary...');
        debugPrint('   Selected image path: $_selectedImagePath');
        
        // Update UI to show uploading status
        notifyListeners();
        
        try {
          final File imageFile = File(_selectedImagePath!);
          
          // Upload to Cloudinary
          final result = await _cloudinaryService.uploadImage(imageFile);
          
          if (result != null) {
            finalProfileImageUrl = result['url'];
            debugPrint('   ✅ Image uploaded successfully!');
            debugPrint('   Cloudinary URL: $finalProfileImageUrl');
            
            // Clear the selected image path
            _selectedImagePath = null;
          } else {
            debugPrint('   ⚠️ Image upload returned null, keeping existing URL');
            _selectedImagePath = null; // Clear it anyway
          }
        } catch (e) {
          debugPrint('   ❌ Image upload failed: $e');
          debugPrint('   Will save profile without updating image');
          _selectedImagePath = null; // Clear it to prevent retry
          // Continue with existing image URL
        }
      } else {
        debugPrint('   No new image selected, keeping existing profileImageUrl');
      }
      
      debugPrint('   Current profileImageUrl: $finalProfileImageUrl');
      debugPrint('   Phone: ${phoneController.text.trim()}');
      debugPrint('   Location: ${locationController.text.trim()}');
      debugPrint('   Vehicle Type: ${vehicleTypeController.text.trim()}');
      debugPrint('   Vehicle Number: ${vehicleNumberController.text.trim()}');

      // STEP 2: Create updated driver object with all data including new image URL
      PickUpModel driver = PickUpModel(
        uid: user.uid,
        fullName: _currentVendor?.fullName ?? usernameController.text.trim(),
        email: _currentVendor?.email ?? emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        location: locationController.text.trim(),
        vehicleType: vehicleTypeController.text.isNotEmpty 
            ? vehicleTypeController.text.trim() 
            : _currentVendor?.vehicleType,
        vehicleNumber: vehicleNumberController.text.isNotEmpty 
            ? vehicleNumberController.text.trim() 
            : _currentVendor?.vehicleNumber,
        profileImageUrl: finalProfileImageUrl, // ✅ Use uploaded or existing URL
        createdAt: _currentVendor?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      debugPrint('   Final driver object profileImageUrl: ${driver.profileImageUrl}');
      debugPrint('   Saving to Firebase...');

      // STEP 3: Save everything to Firebase
      await _repository.saveDriverData(driver);
      
      debugPrint('   ✅ Saved successfully!');
      
      // Update local state with the saved data
      _currentVendor = driver;

      debugPrint('════════════════════════════════════════');

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    debugPrint('   ❌ Error in registerUser: $e');
    _errorMessage = e.toString();
    _isLoading = false;
    notifyListeners();
    return false;
  }
}

  /// Pick image from gallery or camera
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedImagePath = pickedFile.path;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Upload image to Cloudinary and update driver profile
  Future<bool> uploadProfileImage() async {
    if (_selectedImagePath == null || _currentVendor == null) {
      _errorMessage = 'No image selected or user not logged in';
      notifyListeners();
      return false;
    }

    _isUploadingImage = true;
    notifyListeners();

    try {
      final File imageFile = File(_selectedImagePath!);
      
      debugPrint('🔹 Step 1: Uploading to Cloudinary...');
      
      // Upload to Cloudinary using CloudinaryService
      final result = await _cloudinaryService.uploadImage(imageFile);

      if (result == null) {
        throw Exception('Failed to upload image to Cloudinary');
      }

      // Get the secure URL from Cloudinary
      final String downloadUrl = result['url'];
      final String publicId = result['public_id'];

      debugPrint('════════════════════════════════════════');
      debugPrint('✅ STEP 1 COMPLETE: Cloudinary Upload');
      debugPrint('════════════════════════════════════════');
      debugPrint('   Cloudinary URL: $downloadUrl');
      debugPrint('   Public ID: $publicId');
      debugPrint('   URL length: ${downloadUrl.length}');
      debugPrint('   URL is not empty: ${downloadUrl.isNotEmpty}');

      debugPrint('');
      debugPrint('🔹 STEP 2: Creating Updated Driver Model');
      debugPrint('   Current driver UID: ${_currentVendor!.uid}');
      debugPrint('   Current profileImageUrl: ${_currentVendor!.profileImageUrl}');
      debugPrint('   New URL to set: $downloadUrl');
      
      // Update driver profile with new image URL
      final updatedDriver = _currentVendor!.copyWith(
        profileImageUrl: downloadUrl,
        updatedAt: DateTime.now(),
      );
      
      debugPrint('   Updated driver profileImageUrl: ${updatedDriver.profileImageUrl}');

      debugPrint('');
      debugPrint('🔹 Step 3: Saving to Firebase Firestore...');
      debugPrint('   Collection: drivers');
      debugPrint('   Document: ${_currentVendor!.uid}');
      debugPrint('   Old profileImageUrl: ${_currentVendor!.profileImageUrl}');
      debugPrint('   New profileImageUrl: $downloadUrl');
      debugPrint('   updatedDriver.profileImageUrl: ${updatedDriver.profileImageUrl}');
      
      // CRITICAL: Save to Firebase with the new URL
      await _repository.saveDriverData(updatedDriver);
      
      debugPrint('✅ Step 3 Complete: Saved to Firebase!');
      debugPrint('');
      
      // CRITICAL: Update local state with the saved driver data
      // This ensures _currentVendor has the new image URL for when Save Changes is clicked
      _currentVendor = updatedDriver;
      
      debugPrint('🔹 Step 4: Updating local state...');
      debugPrint('   _currentVendor updated!');
      debugPrint('   _currentVendor.profileImageUrl: ${_currentVendor!.profileImageUrl}');
      debugPrint('   _currentVendor.uid: ${_currentVendor!.uid}');
      
      // Clear selected image path
      _selectedImagePath = null;
      _isUploadingImage = false;
      
      // Notify listeners to update UI
      notifyListeners();
      
      debugPrint('✅ Step 4 Complete: UI notified!');
      debugPrint('');
      debugPrint('════════════════════════════════════════');
      debugPrint('✅✅✅ IMAGE UPLOAD COMPLETE! ✅✅✅');
      debugPrint('════════════════════════════════════════');
      debugPrint('🎉 Final profileImageUrl in _currentVendor: ${_currentVendor!.profileImageUrl}');
      debugPrint('   URL length: ${_currentVendor!.profileImageUrl?.length ?? 0}');
      debugPrint('   IMPORTANT: This URL is now in memory and Firebase!');
      debugPrint('   When you click "Save Changes", this URL will be preserved!');
      debugPrint('════════════════════════════════════════');

      return true;
    } catch (e) {
      debugPrint('❌ Upload failed: $e');
      _errorMessage = e.toString();
      _isUploadingImage = false;
      notifyListeners();
      return false;
    }
  }

  /// Show image source selection dialog
  Future<void> selectImageSource(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF2196F3)),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await pickImage(source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF2196F3)),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await pickImage(source: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Clear selected image
  void clearSelectedImage() {
    _selectedImagePath = null;
    notifyListeners();
  }
}