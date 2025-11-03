import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_elevated_button.dart';
import 'package:fresh_fold_pickup/Settings/constants/sized_box.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_pages.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';
import 'package:fresh_fold_pickup/Settings/utils/call_utils.dart';
import 'package:provider/provider.dart';
import '../home/view_model/home_view_model.dart';
import '../add_billing/view_model/billing_view_model.dart';
import 'view_model/order_detail_view_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderCardData orderData;

  const OrderDetailScreen({
    super.key,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderDetailViewModel(orderData: orderData),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Order Details'),
        body: Consumer<OrderDetailViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
                  // Order Details Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          PColors.primaryColor,
                          PColors.secondoryColor,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow(
                          'Customer Name',
                          viewModel.customerName,
                          Icons.person_outline,
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(
                          'Schedule ID',
                          viewModel.orderId,
                          Icons.tag,
                        ),
                        _buildInfoRow(
                          'Status',
                          viewModel.formattedStatus.toUpperCase(),
                          Icons.info_outline,
                        ),
                        _buildInfoRow(
                          'Service Type',
                          viewModel.serviceType,
                          Icons.star_outline,
                        ),
                        _buildInfoRow(
                          'Wash Type',
                          viewModel.washType,
                          Icons.local_laundry_service,
                        ),
                        _buildInfoRow(
                          'Pickup Date',
                          viewModel.pickupDate,
                          Icons.calendar_today,
                        ),
                        _buildInfoRow(
                          'Time Slot',
                          viewModel.formattedTimeSlot,
                          Icons.access_time,
                        ),
                        _buildInfoRow(
                          'Pickup Location',
                          viewModel.pickupAddress,
                          Icons.location_on,
                          isAddress: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Pickup Information Section
                  Text(
                    'Pickup Information',
                    style: PTextStyles.displaySmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: PColors.darkGray,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(20),
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
                      children: [
                        _buildDetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Pick up date',
                          value: viewModel.pickupDate,
                        ),
                        SizedBox(height: 16),
                        Divider(height: 1, color: PColors.lightGray),
                        SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Pick up time',
                          value: viewModel.pickupTime,
                        ),
                        SizedBox(height: 16),
                        Divider(height: 1, color: PColors.lightGray),
                        SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Pick up address',
                          value: viewModel.pickupAddress,
                          isAddress: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Contact Information Section
                  Text(
                    'Contact Information',
                    style: PTextStyles.displaySmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: PColors.darkGray,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildDetailCardRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone number',
                    value: viewModel.phoneNumber,
                  ),
                  SizeBoxH(12),
                  _buildDetailCardRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: viewModel.email,
                  ),
                  SizeBoxH(28),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            CallUtils.confirmAndCall(
                              context,
                              viewModel.phoneNumber,
                              viewModel.customerName,
                            );
                          },
                          icon: Icon(Icons.phone, color: PColors.white),
                          label: Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PColors.primaryColor,
                            foregroundColor: PColors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              PPages.directions,
                              arguments: {
                                'destinationAddress': viewModel.pickupAddress,
                                'latitude': viewModel.latitude,
                                'longitude': viewModel.longitude,
                              },
                            );
                          },
                          icon: Icon(Icons.directions, color: PColors.primaryColor),
                          label: Text('Directions'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PColors.primaryColor,
                            side: BorderSide(color: PColors.primaryColor),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizeBoxH(20),
                  // Billing button
                  Consumer<BillingViewModel>(
                    builder: (context, billingViewModel, child) {
                      // Check if billing already exists for this order
                      final hasBilling = billingViewModel.currentBilling?.scheduleId == viewModel.orderData.schedule.scheduleId;
                      final paymentStatus = billingViewModel.paymentStatus;
                      
                      String buttonText;
                      IconData buttonIcon;
                      
                      if (hasBilling) {
                        switch (paymentStatus) {
                          case 'pay_request':
                            buttonText = 'View Bill';
                            buttonIcon = Icons.receipt;
                            break;
                          case 'paid':
                            buttonText = 'View Bill';
                            buttonIcon = Icons.check_circle;
                            break;
                          default:
                            buttonText = 'View Bill';
                            buttonIcon = Icons.receipt_long;
                        }
                      } else {
                        buttonText = 'Set Bill Amount';
                        buttonIcon = Icons.payment;
                      }
                      
                      return CustomElavatedTextButton(
                        text: buttonText,
                        icon: Icon(buttonIcon, color: Colors.white, size: 20),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            PPages.billing,
                            arguments: {
                              'orderData': viewModel.orderData,
                            },
                          );
                        },
                      );
                    },
                  ),
                  SizeBoxH(20),
                  // Update Order Status Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: PColors.lightGray,
                        width: 1.5,
                      ),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Order Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: PColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildStatusButton(
                          context,
                          viewModel,
                          'Mark as Picked Up',
                          'picked_up',
                          Colors.blue,
                        ),
                        _buildStatusButton(
                          context,
                          viewModel,
                          'Mark as Delivered',
                          'delivered',
                          Colors.indigo,
                        ),
                        _buildStatusButton(
                          context,
                          viewModel,
                          'Mark as Paid',
                          'paid',
                          PColors.successGreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isAddress = false,
  }) {
    return Row(
      crossAxisAlignment: isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PColors.lightBlue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: PColors.primaryColor),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: PTextStyles.bodySmall.copyWith(
                  color: PColors.darkGray.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: PTextStyles.bodyMedium.copyWith(
                  color: PColors.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isAddress = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: isAddress ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCardRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
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
      child: _buildDetailRow(
        icon: icon,
        label: label,
        value: value,
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    OrderDetailViewModel viewModel,
    String label,
    String status,
    Color color,
  ) {
    final bool isCurrentStatus = viewModel.isCurrentStatus(status);
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isCurrentStatus
              ? null
              : () => _showConfirmDialog(context, label, viewModel, status),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentStatus ? PColors.lightGray : color,
            disabledBackgroundColor: PColors.lightGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCurrentStatus)
                Icon(Icons.check_circle, size: 20, color: PColors.darkGray)
              else
                Icon(Icons.arrow_forward, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                isCurrentStatus ? 'Current Status' : label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCurrentStatus ? PColors.darkGray : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}

void _showConfirmDialog(
  BuildContext context,
  String label,
  OrderDetailViewModel viewModel,
  String newStatus,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => _ConfirmStatusDialog(
      label: label,
      viewModel: viewModel,
      newStatus: newStatus,
    ),
  );
}

class _ConfirmStatusDialog extends StatefulWidget {
  final String label;
  final OrderDetailViewModel viewModel;
  final String newStatus;

  const _ConfirmStatusDialog({
    required this.label,
    required this.viewModel,
    required this.newStatus,
  });

  @override
  State<_ConfirmStatusDialog> createState() => _ConfirmStatusDialogState();
}

class _ConfirmStatusDialogState extends State<_ConfirmStatusDialog> {
  bool _isUpdating = false;

  Future<void> _handleConfirm() async {
    setState(() {
      _isUpdating = true;
    });

    bool success = false;
    String? errorMsg;

    try {
      success = await widget.viewModel.updateOrderStatus(widget.newStatus).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Update timed out. Please check your internet connection.'),
      );

      if (!success) {
        errorMsg = widget.viewModel.errorMessage ?? 'Failed to update status';
      }
    } catch (e) {
      success = false;
      errorMsg = e.toString();
    }

    if (!mounted) return;

    // Close dialog
    Navigator.of(context).pop();

    // Show result
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated successfully!'),
          backgroundColor: PColors.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate back to home
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg ?? 'Failed to update status'),
          backgroundColor: PColors.errorRed,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isUpdating ? 'Updating...' : 'Confirm Status Update'),
      content: _isUpdating
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: PColors.primaryColor),
                SizedBox(height: 16),
                Text('Updating status to ${widget.newStatus}...'),
              ],
            )
          : Text('Are you sure you want to "${widget.label}"?'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: _isUpdating
          ? [] // No buttons while updating
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Confirm', style: TextStyle(color: PColors.white)),
              ),
            ],
    );
  }
}