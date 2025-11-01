import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_fold_pickup/Features/home/view_model/home_view_model.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_pages.dart';
import 'order_card.dart';

class TodayWidgets extends StatelessWidget {
  const TodayWidgets({super.key});

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

        final todayOrders = viewModel.todayOrders;

        if (todayOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No orders for today',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: ListView.builder(
            itemCount: todayOrders.length,
            itemBuilder: (context, index) {
              final orderData = todayOrders[index];
              
              return OrderCard(
                customerName: orderData.customerName,
                orderId: orderData.orderId,
                pickupDate: orderData.pickupDate,
                pickupTime: orderData.pickupTime,
                pickupAddress: orderData.pickupAddress,
                pickupPhone: orderData.pickupPhone,
                statusLabel: orderData.statusLabel,
                statusColor: orderData.statusColor,
                onCall: () {},
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    PPages.orderDetail,
                    arguments: {
                      'orderData': orderData,
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}