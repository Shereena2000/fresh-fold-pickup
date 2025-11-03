import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';
import 'package:fresh_fold_pickup/Settings/utils/call_utils.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Help & Support'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: PColors.primaryColor,
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'How can we help you?',
                    style: PTextStyles.displaySmall.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: PColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Contact Options
            Text(
              'Contact Us',
              style: PTextStyles.displaySmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PColors.darkGray,
              ),
            ),
            SizedBox(height: 16),

            _buildContactCard(
              context,
              icon: Icons.phone,
              title: 'Phone Support',
              subtitle: '+1 (555) 123-4567',
              description: 'Available 24/7 for urgent issues',
              onTap: () {
                CallUtils.makePhoneCall(context, '+15551234567');
              },
            ),

            SizedBox(height: 12),

            _buildContactCard(
              context,
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@freshfold.com',
              description: 'Response within 24 hours',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening email client...')),
                );
              },
            ),

            SizedBox(height: 12),

            _buildContactCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              description: 'Available Mon-Fri, 9 AM - 6 PM',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Live chat - Coming soon!')),
                );
              },
            ),

            SizedBox(height: 32),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: PTextStyles.displaySmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PColors.darkGray,
              ),
            ),
            SizedBox(height: 16),

            _buildFAQ(
              'How do I take an order?',
              'Go to the Home screen, find an available order, and tap the "Take Order" button. The order will then appear in "My Deliveries".',
            ),

            _buildFAQ(
              'How do I update order status?',
              'Open any order from "My Deliveries", scroll down to the "Update Order Status" section, select the new status, and tap "Update Status".',
            ),

            _buildFAQ(
              'How do I set billing for an order?',
              'In the order details, tap "Set Bill Amount", select items and quantities, then tap "Send Payment Request". The customer will receive the payment request.',
            ),

            _buildFAQ(
              'What if I can\'t complete a delivery?',
              'Contact our support team immediately. Do not cancel orders without prior approval. We\'ll help reassign the order if necessary.',
            ),

            _buildFAQ(
              'How do I update my profile photo?',
              'Go to Profile → Edit Profile → Tap the camera icon on your photo → Select from camera or gallery → Confirm upload.',
            ),

            _buildFAQ(
              'How are payments handled?',
              'Most orders are Cash on Delivery (COD). After setting the bill amount and completing delivery, collect cash from the customer.',
            ),

            _buildFAQ(
              'What if the customer is not available?',
              'Try calling the customer using the Call button. If still unreachable, contact support for instructions.',
            ),

            _buildFAQ(
              'How do I search for my deliveries?',
              'In "My Deliveries", use the search bar at the top to search by customer name or order ID.',
            ),

            SizedBox(height: 32),

            // Support Hours
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PColors.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.access_time, color: PColors.primaryColor, size: 28),
                  SizedBox(height: 8),
                  Text(
                    'Support Hours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM\nSunday: Closed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: PColors.darkGray,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Emergency Support: 24/7',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PColors.primaryColor,
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

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PColors.lightGray),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: PColors.primaryColor, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PColors.darkGray,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: PColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
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

