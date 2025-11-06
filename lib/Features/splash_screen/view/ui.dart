import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_pages.dart';
import '../../auth/view_model.dart/auth_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _bubbleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _bubbleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Fade animation for overall entrance
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Scale animation for logo with bounce effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Slide animation for tagline
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Pulse animation for loading indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer animation for text
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Bubble animation for background
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();
    _bubbleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.linear),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _slideController.forward();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3)); // wait for splash animations

    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      final authViewModel = context.read<AuthViewModel>();

      if (user != null) {
        // User is logged in, load driver data
        await authViewModel.loadDriverData();
        
        if (!mounted) return;

        // Check if driver data was loaded successfully
        if (authViewModel.currentVendor != null) {
          // Navigate to home
          Navigator.of(context).pushNamedAndRemoveUntil(
            PPages.wrapperPageUi,
            (route) => false,
          );
        } else {
          // Driver data not found, go to registration
          Navigator.of(context).pushNamedAndRemoveUntil(
            PPages.registration,
            (route) => false,
          );
        }
      } else {
        // No user logged in, go to login
        Navigator.of(context).pushNamedAndRemoveUntil(
          PPages.login,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error checking auth: $e');
      if (!mounted) return;
      // On error, go to login
      Navigator.of(context).pushNamedAndRemoveUntil(
        PPages.login,
        (route) => false,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PColors.primaryColor,
              PColors.secondoryColor,
              PColors.black.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated floating bubbles background
            _buildFloatingBubbles(size),

            // Gradient overlay for depth
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Animated logo with glow effect
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildLogoWithGlow(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App name with shimmer effect
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildShimmerText(
                        "Growblic captain",
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),


                

                    const Spacer(flex: 2),

                    // Animated loading indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildModernLoadingIndicator(),
                    ),

                    const SizedBox(height: 24),

                    // Loading text
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          "Loading your dashboard...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom branding
                  
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating bubbles animation for background
  Widget _buildFloatingBubbles(Size size) {
    return AnimatedBuilder(
      animation: _bubbleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final random = Random(index);
            final startX = random.nextDouble() * size.width;
            final startY = size.height + random.nextDouble() * 200;
            final endY = -200 - random.nextDouble() * 200;
            final bubbleSize = 40 + random.nextDouble() * 80;
            final opacity = 0.03 + random.nextDouble() * 0.07;
            
            final currentY = startY + (endY - startY) * (_bubbleAnimation.value + index * 0.15) % 1.0;
            final currentX = startX + sin((_bubbleAnimation.value + index) * pi * 2) * 30;
            
            return Positioned(
              left: currentX,
              top: currentY,
              child: Container(
                width: bubbleSize,
                height: bubbleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(opacity),
                      Colors.white.withOpacity(opacity * 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Logo with glow effect
  Widget _buildLogoWithGlow() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: PColors.lightBlue.withOpacity(0.5),
              blurRadius: 60,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo/app_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  // Shimmer text effect
  Widget _buildShimmerText(String text, {required double fontSize, required FontWeight fontWeight}) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.white,
                Colors.white.withOpacity(0.7),
              ],
              stops: [
                max(0.0, _shimmerAnimation.value - 0.3),
                _shimmerAnimation.value,
                min(1.0, _shimmerAnimation.value + 0.3),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modern loading indicator with pulse animation
  Widget _buildModernLoadingIndicator() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          // Inner spinning indicator
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          // Center dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

