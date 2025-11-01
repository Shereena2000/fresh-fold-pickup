import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/vendor_model.dart';
import '../repositories/auth_repositories.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
  PickUpModel? _currentVendor;
  PickUpModel? get currentVendor => _currentVendor;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
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

  //sigin
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

      // Load vendor data after successful login
      await loadVendorData();

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
      _currentVendor = null; // Clear vendor data
      
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
}