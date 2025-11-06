import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  color: PColors.primaryColor,
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Growblic Captain Privacy Policy',
                    style: PTextStyles.displaySmall.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: PColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Last updated: November 2024',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24),

            // Introduction
            _buildSection(
              'Introduction',
              'Welcome to Growblic Captain Driver App. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our driver application.',
            ),

            // Data Collection
            _buildSection(
              '1. Information We Collect',
              'We collect the following personal information:\n\n'
              '• Personal Details: Full name, email address, phone number\n'
              '• Location Data: Your current location and delivery addresses\n'
              '• Vehicle Information: Vehicle type and registration number\n'
              '• Profile Photo: Optional profile image uploaded by you\n'
              '• Delivery Records: Orders you\'ve picked up and delivered\n'
              '• Performance Data: Delivery statistics and completion rates',
            ),

            // How We Use Data
            _buildSection(
              '2. How We Use Your Information',
              'Your information is used for the following purposes:\n\n'
              '• Order Management: Process and track laundry pickups and deliveries\n'
              '• Communication: Contact customers and provide support\n'
              '• Payment Processing: Manage cash on delivery and billing\n'
              '• Service Improvement: Analyze performance and enhance our services\n'
              '• Navigation: Provide directions to pickup and delivery locations\n'
              '• Notifications: Send important updates about orders and account',
            ),

            // Data Sharing
            _buildSection(
              '3. Data Sharing and Disclosure',
              'We share your information only in the following circumstances:\n\n'
              '• With Customers: Your name and contact details are shared with customers for their orders\n'
              '• With Admin: Growblic Captain administrators can access your delivery records\n'
              '• Service Providers: We use Firebase, Cloudinary, and Google Maps services\n'
              '• Legal Requirements: When required by law or to protect our rights',
            ),

            // Data Security
            _buildSection(
              '4. Data Security',
              'We implement robust security measures to protect your information:\n\n'
              '• Secure Storage: Data stored using Firebase Cloud Firestore with encryption\n'
              '• Secure Authentication: Firebase Authentication with industry-standard security\n'
              '• HTTPS: All data transmission uses secure HTTPS protocol\n'
              '• Access Control: Role-based access restrictions\n'
              '• Regular Updates: Security patches and updates applied regularly',
            ),

            // Your Rights
            _buildSection(
              '5. Your Privacy Rights',
              'You have the following rights regarding your personal data:\n\n'
              '• Access: View all personal information we hold about you\n'
              '• Correction: Update or correct your personal details\n'
              '• Deletion: Request deletion of your account and data\n'
              '• Opt-out: Decline non-essential communications\n'
              '• Data Portability: Request a copy of your data in portable format\n'
              '• Withdraw Consent: Stop using our services at any time',
            ),

            // Location Data
            _buildSection(
              '6. Location Information',
              'We collect and use your location data to:\n\n'
              '• Navigate to pickup and delivery addresses\n'
              '• Track delivery progress in real-time\n'
              '• Provide accurate directions\n'
              '• Optimize delivery routes\n\n'
              'You can disable location services in your device settings, but this may limit app functionality.',
            ),

            // Data Retention
            _buildSection(
              '7. Data Retention',
              'We retain your information for as long as:\n\n'
              '• Your account is active\n'
              '• Required for service delivery\n'
              '• Necessary for legal compliance\n'
              '• Needed for dispute resolution\n\n'
              'When you delete your account, we will delete or anonymize your personal information within 30 days, except where retention is required by law.',
            ),

            // Children's Privacy
            _buildSection(
              '8. Children\'s Privacy',
              'Our services are not intended for individuals under 18 years of age. We do not knowingly collect personal information from children. If you are a parent or guardian and believe we have collected information from a child, please contact us immediately.',
            ),

            // Changes to Policy
            _buildSection(
              '9. Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by:\n\n'
              '• Posting the new Privacy Policy in the app\n'
              '• Updating the "Last updated" date\n'
              '• Sending notifications for significant changes\n\n'
              'We encourage you to review this Privacy Policy periodically.',
            ),

            // Contact
            _buildSection(
              '10. Contact Us',
              'If you have questions or concerns about this Privacy Policy, please contact us:\n\n'
              '• Email: freshfold.growblic@gmail.com\n'
              '• Phone: +91 92531 41908\n\n'
              'We will respond to your inquiry within 48 hours.',
            ),

            SizedBox(height: 24),

            // Footer
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PColors.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: PColors.primaryColor, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your privacy is important to us. We are committed to protecting your personal information.',
                      style: TextStyle(
                        fontSize: 13,
                        color: PColors.darkGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PTextStyles.displaySmall.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: PColors.primaryColor,
            ),
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: PTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              color: PColors.darkGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

