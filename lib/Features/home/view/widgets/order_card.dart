import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_elevated_button.dart';
import 'package:fresh_fold_pickup/Settings/constants/sized_box.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';

class OrderCard extends StatelessWidget {
  final String customerName;
  final String orderId;
  final String pickupDate;
  final String pickupTime;
  final String pickupAddress;
  final String pickupPhone;
  final String statusLabel;
  final Color? statusColor;
  final VoidCallback? onCall;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.customerName,
    required this.orderId,
    required this.pickupDate,
    required this.pickupTime,
    required this.pickupAddress,
    required this.pickupPhone,
    required this.statusLabel,
    this.statusColor,
    this.onCall,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color pillColor = (statusColor ?? PColors.successGreen).withOpacity(
      0.12,
    );
    final Color pillText = statusColor ?? PColors.successGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PColors.primaryColor.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              spreadRadius: 0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: PColors.lightBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_mall_outlined,
                    color: PColors.primaryColor,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order by $customerName',
                        style: PTextStyles.displaySmall.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PColors.darkGray,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Order ID: $orderId',
                        style: PTextStyles.bodySmall.copyWith(
                          color: PColors.darkGray.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: PTextStyles.labelSmall.copyWith(
                      color: pillText,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(height: 1, color: PColors.lightGray),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: PColors.primaryColor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pick up date: $pickupDate',
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.darkGray,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: PColors.primaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pick up time: $pickupTime',
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.darkGray,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: PColors.primaryColor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pick up address: $pickupAddress',
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.darkGray,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: PColors.primaryColor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pickup phone number: $pickupPhone',
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.darkGray,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onCall,
                  style: TextButton.styleFrom(
                    foregroundColor: PColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text('Call'),
                ),
              ],
            ),
            SizeBoxH(10),
            CustomElavatedTextButton(
              text: "Take Order",
              onPressed: onTap, // Use onTap for Take Order action
              height: 45,
            ),
          ],
        ),
      ),
    );
  }
}
