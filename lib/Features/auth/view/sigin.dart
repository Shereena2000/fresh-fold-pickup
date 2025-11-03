import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/constants/text_styles.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../Settings/common/widgets/custom_text_feild.dart';
import '../common/widgets/heading_section.dart';
import '../view_model.dart/auth_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeadingSection(title: "Welcome Back !"),

                  SizeBoxH(20),

                  Consumer<AuthViewModel>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          // Email Field
                          CustomTextFeild(
                            controller: provider.emailController,
                            hintText: "Email Address",
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizeBoxH(12),

                          // Password Field
                          CustomTextFeild(
                            controller: provider.passwordController,
                            hintText: "Password",
                            obscureText: !provider.isPasswordVisible,
                            suffixIcon: IconButton(
                              onPressed: provider.togglePasswordVisibility,
                              icon: Icon(
                                provider.isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: PColors.black,
                              ),
                            ),
                            sufixfn: () {},
                          ),

                          // Error Message
                          if (provider.error != null) ...[
                            SizeBoxH(12),
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
                                provider.error!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],

                          SizeBoxH(20),

                          // Sign In Button
                          CustomElavatedTextButton(
                            text: provider.isLoading
                                ? "Signing In..."
                                : "Sign In",
                            onPressed: provider.isLoading
                                ? null // Use null instead of empty function
                                : () async {
                                    final success = await provider.signIn();
                                    if (success && context.mounted) {
                                      provider.clearError();
                                      provider.clearLoginData();
                                      
                                      // Check if profile is complete
                                      if (provider.isDriverProfileComplete) {
                                        // Profile complete, go to home
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          PPages.wrapperPageUi,
                                          (route) => false,
                                        );
                                      } else {
                                        // Profile incomplete, go to registration
                                        Navigator.pushReplacementNamed(
                                          context,
                                          PPages.registration,
                                        );
                                      }
                                    }
                                  },
                          ),

                          SizeBoxH(12),

                          // Sign Up Navigation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: getTextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: PColors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  provider.clearError();
                                  provider.clearLoginData();
                                  Navigator.pushReplacementNamed(
                                    context,
                                    PPages.signUp,
                                  );
                                },
                                child: Text(
                                  "Sign Up",
                                  style: getTextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: PColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizeBoxH(20),

                          // Forgot Password
                          GestureDetector(
                            onTap: () =>
                                _showForgotPasswordDialog(context, provider),
                            child: Text(
                              "Forgot Password?",
                              style: getTextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: PColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context, AuthViewModel provider) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: PColors.secondoryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text("Reset Password", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter your email address and we'll send you a link to reset your password.",
                style: TextStyle(color: PColors.lightGray, fontSize: 14),
              ),
              SizeBoxH(16),
              CustomTextFeild(
                controller: emailController,
                hintText: "Email Address",
                keyboardType: TextInputType.emailAddress,
                filColor: PColors.white,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await provider.sendPasswordResetEmail(
                  emailController.text,
                );
                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send password reset email'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PColors.primaryColor,
              ),
              child: Text(
                "Send Reset Link",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
