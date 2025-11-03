import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'p_colors.dart';

class CallUtils {
  /// Make a phone call
  static Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    // Clean the phone number (remove spaces, dashes, etc.)
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleanedNumber.isEmpty) {
      _showErrorSnackBar(context, 'Invalid phone number');
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: cleanedNumber);

    try {
      final canMakeCall = await canLaunchUrl(phoneUri);
      
      if (canMakeCall) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackBar(context, 'Cannot make phone calls on this device');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to make call: ${e.toString()}');
    }
  }

  /// Show confirmation dialog before calling
  static Future<void> confirmAndCall(BuildContext context, String phoneNumber, String customerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone, color: PColors.primaryColor),
            SizedBox(width: 12),
            Text('Call Customer?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to call:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              customerName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: PColors.primaryColor),
                SizedBox(width: 6),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 15,
                    color: PColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: Icon(Icons.phone, size: 18),
            label: Text('Call Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await makePhoneCall(context, phoneNumber);
    }
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: PColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

