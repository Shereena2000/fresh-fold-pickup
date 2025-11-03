import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'About'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            
            // App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: PColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // App Name
            Text(
              'Fresh Fold Pickup',
              style: PTextStyles.displaySmall.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: PColors.primaryColor,
              ),
            ),
            
            SizedBox(height: 8),
            
            // Version
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: PColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: PColors.primaryColor,
                ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Tagline
            Text(
              'Driver Application',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            SizedBox(height: 32),

            // Description Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PColors.lightGray),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Fresh Fold',
                    style: PTextStyles.displaySmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: PColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Fresh Fold Pickup is a professional laundry pickup and delivery service dedicated to making laundry hassle-free for our customers. As a driver, you are an essential part of our service, ensuring timely pickups and deliveries with excellent customer care.',
                    style: TextStyle(
                      fontSize: 14,
                      color: PColors.darkGray,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Our mission is to provide convenient, reliable, and eco-friendly laundry services while creating opportunities for dedicated drivers like you.',
                    style: TextStyle(
                      fontSize: 14,
                      color: PColors.darkGray,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Features Grid
            Text(
              'App Features',
              style: PTextStyles.displaySmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PColors.darkGray,
              ),
            ),
            SizedBox(height: 16),

            _buildFeatureCard(
              icon: Icons.home,
              title: 'Browse Orders',
              description: 'View all available laundry orders in your area',
            ),

            _buildFeatureCard(
              icon: Icons.delivery_dining,
              title: 'My Deliveries',
              description: 'Track your active and completed deliveries',
            ),

            _buildFeatureCard(
              icon: Icons.navigation,
              title: 'GPS Navigation',
              description: 'Get turn-by-turn directions to pickup locations',
            ),

            _buildFeatureCard(
              icon: Icons.phone,
              title: 'Call Customers',
              description: 'Direct calling to communicate with customers',
            ),

            _buildFeatureCard(
              icon: Icons.payment,
              title: 'Billing Management',
              description: 'Set bills and manage cash on delivery payments',
            ),

            _buildFeatureCard(
              icon: Icons.search,
              title: 'Smart Search',
              description: 'Quickly find orders by name or order ID',
            ),

            SizedBox(height: 24),

            // Technology Stack
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [PColors.primaryColor, PColors.secondoryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: PColors.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.code, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Built with Flutter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Powered by Firebase, Cloudinary & Google Maps',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Copyright
            Text(
              '© 2024 Fresh Fold. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            Text(
              'Made with ❤️ for our amazing drivers',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PColors.lightGray.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: PColors.primaryColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: PColors.darkGray,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PColors.lightGray.withOpacity(0.5)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: PColors.darkGray,
            ),
          ),
          iconColor: PColors.primaryColor,
          collapsedIconColor: Colors.grey,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  color: PColors.darkGray.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

