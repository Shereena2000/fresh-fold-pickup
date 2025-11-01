import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Static data
    final todayPickups = 12;
    final todayDeliveries = 8;
    final todayEarnings = 2850.00;
    final weeklyEarnings = 18250.00;
    final monthlyEarnings = 75800.00;

    return Scaffold(
      appBar: CustomAppBar(title: 'Earnings Summary'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Stats Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [PColors.primaryColor, PColors.secondoryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Summary',
                    style: PTextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Pickups',
                          todayPickups.toString(),
                          Icons.local_shipping_outlined,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                      Expanded(
                        child: _buildStatItem(
                          'Deliveries',
                          todayDeliveries.toString(),
                          Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white.withOpacity(0.3)),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Earnings',
                        style: PTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '₹${todayEarnings.toStringAsFixed(2)}',
                        style: PTextStyles.displaySmall.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Period Cards
            _buildPeriodCard(
              'Weekly Earnings',
              '₹${weeklyEarnings.toStringAsFixed(2)}',
              Icons.calendar_view_week,
              PColors.primaryColor,
            ),
            SizedBox(height: 12),
            _buildPeriodCard(
              'Monthly Earnings',
              '₹${monthlyEarnings.toStringAsFixed(2)}',
              Icons.calendar_month,
              PColors.secondoryColor,
            ),
            SizedBox(height: 20),
            // Recent Transactions
            Text(
              'Recent Transactions',
              style: PTextStyles.displaySmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PColors.darkGray,
              ),
            ),
            SizedBox(height: 12),
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: PTextStyles.displaySmall.copyWith(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: PTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColors.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PTextStyles.bodyMedium.copyWith(
                    color: PColors.darkGray.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  amount,
                  style: PTextStyles.displaySmall.copyWith(
                    color: PColors.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      _Transaction('Order #1234', 'Delivery Payment', 350.00, '2 hours ago'),
      _Transaction('Order #1231', 'Pickup Payment', 250.00, '3 hours ago'),
      _Transaction('Order #1228', 'Delivery Payment', 420.00, '5 hours ago'),
      _Transaction('Order #1225', 'Pickup Payment', 380.00, 'Yesterday'),
      _Transaction('Order #1220', 'Delivery Payment', 310.00, 'Yesterday'),
    ];

    return Column(
      children: transactions.map((txn) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PColors.lightGray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: PColors.successGreen,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.orderId,
                      style: PTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PColors.darkGray,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      txn.description,
                      style: PTextStyles.bodySmall.copyWith(
                        color: PColors.darkGray.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      txn.time,
                      style: PTextStyles.bodySmall.copyWith(
                        color: PColors.darkGray.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${txn.amount.toStringAsFixed(2)}',
                style: PTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: PColors.successGreen,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Transaction {
  final String orderId;
  final String description;
  final double amount;
  final String time;

  _Transaction(this.orderId, this.description, this.amount, this.time);
}

