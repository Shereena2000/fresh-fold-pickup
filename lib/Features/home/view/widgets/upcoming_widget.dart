import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_fold_pickup/Features/home/view_model/home_view_model.dart';
import 'package:fresh_fold_pickup/Features/delivery/view_model/delivery_view_model.dart';
import 'package:fresh_fold_pickup/Features/auth/view_model.dart/auth_view_model.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/call_utils.dart';
import 'order_card.dart';

class UpcomingWidget extends StatelessWidget {
  const UpcomingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.refreshOrders(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final upcomingOrders = viewModel.upcomingOrders;

        if (upcomingOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No upcoming orders',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: upcomingOrders.length,
            itemBuilder: (context, index) {
              final orderData = upcomingOrders[index];
              
              return OrderCard(
                customerName: orderData.customerName,
                orderId: orderData.orderId,
                pickupDate: orderData.pickupDate,
                pickupTime: orderData.pickupTime,
                pickupAddress: orderData.pickupAddress,
                pickupPhone: orderData.pickupPhone,
                statusLabel: orderData.statusLabel,
                statusColor: orderData.statusColor,
                onCall: () {
                  CallUtils.confirmAndCall(
                    context,
                    orderData.pickupPhone,
                    orderData.customerName,
                  );
                },
                onTap: () async {
                  // Show Take Order confirmation
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Take This Order?'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID: ${orderData.orderId}'),
                          SizedBox(height: 8),
                          Text('Customer: ${orderData.customerName}'),
                          SizedBox(height: 8),
                          Text('Pickup: ${orderData.pickupDate} at ${orderData.pickupTime}'),
                          SizedBox(height: 12),
                          Text(
                            'This order will be assigned to you and will appear in "My Deliveries".',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PColors.primaryColor,
                          ),
                          child: Text('Take Order', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    final deliveryViewModel = context.read<DeliveryViewModel>();
                    final authViewModel = context.read<AuthViewModel>();
                    
                    // Set driver ID if not already set
                    if (authViewModel.currentVendor != null) {
                      deliveryViewModel.setDriverId(authViewModel.currentVendor!.uid);
                    }
                    
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: CircularProgressIndicator(color: PColors.primaryColor),
                      ),
                    );
                    
                    // Take the order
                    final success = await deliveryViewModel.takeOrder(
                      userId: orderData.schedule.userId,
                      scheduleId: orderData.schedule.scheduleId,
                    );
                    
                    // Close loading
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    
                    // Show result
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order assigned to you! Check "My Deliveries"'),
                            backgroundColor: PColors.successGreen,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        
                        // Refresh home screen to remove taken order
                        context.read<HomeViewModel>().refreshOrders();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              deliveryViewModel.errorMessage ?? 'Failed to take order',
                            ),
                            backgroundColor: PColors.errorRed,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}


