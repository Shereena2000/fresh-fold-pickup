import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_tab_section.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import '../../home/view/widgets/order_card.dart';

// Tab configuration
final List<String> deliveryTabTitles = ['Today', 'All'];

final List<Widget> deliveryTabContents = [
  TodayDeliveryWidgets(),
  AllDeliveryWidgets(),
];

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Deliveries'),
      body: CustomTabSection(
        tabTitles: deliveryTabTitles,
        tabContents: deliveryTabContents,
      ),
    );
  }
}

class TodayDeliveryWidgets extends StatelessWidget {
  const TodayDeliveryWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return OrderCard(
            customerName: 'Customer ${index + 1}',
            orderId: 'DEL-${2000 + index}',
            pickupDate: '01 Jan 2025',
            pickupTime: '2:00 PM',
            pickupAddress: 'Naini Station Rd, Ambedkar Nagar, Prayagraj, Uttar Pradesh 211008',
            pickupPhone: '987654321${index % 10}',
            statusLabel: 'Ready',
            statusColor: PColors.successGreen,
            onCall: () {},
            onTap: () {},
          );
        },
      ),
    );
  }
}

class AllDeliveryWidgets extends StatelessWidget {
  const AllDeliveryWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          final bool isCompleted = index % 3 == 0;
          return OrderCard(
            customerName: 'Customer ${index + 1}',
            orderId: 'DEL-${2000 + index}',
            pickupDate: '01 Jan 2025',
            pickupTime: '${(index % 12 + 8)}:00 ${index % 2 == 0 ? 'AM' : 'PM'}',
            pickupAddress: 'Naini Station Rd, Ambedkar Nagar, Prayagraj, Uttar Pradesh 211008',
            pickupPhone: '987654321${index % 10}',
            statusLabel: isCompleted ? 'Delivered' : 'Pending',
            statusColor: isCompleted ? PColors.successGreen : PColors.primaryColor,
            onCall: () {},
            onTap: () {},
          );
        },
      ),
    );
  }
}

