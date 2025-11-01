import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Static demo data
    final items = const [
      _BillingItem(name: 'Shirt', price: 20.0, quantity: 2),
      _BillingItem(name: 'Pants', price: 35.0, quantity: 1),
      _BillingItem(name: 'Jacket', price: 80.0, quantity: 1),
    ];

    final double subtotal = items
        .map((e) => e.price * e.quantity)
        .fold(0.0, (a, b) => a + b);
    final double tax = subtotal * 0.05; // 5% demo tax
    final double total = subtotal + tax;

    return Scaffold(
      appBar: CustomAppBar(title: 'Billing'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            SizedBox(height: 16),
            _buildAddItemButton(),
            SizedBox(height: 16),
            _buildItemsCard(items),
            SizedBox(height: 16),
            _buildTotalsCard(subtotal, tax, total),
            SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [PColors.primaryColor, PColors.secondoryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: PTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          _headerRow('Service Type', 'Express'),
          _headerRow('Wash Type', 'Wash & Steam Press'),
          _headerRow('Schedule ID', 'SCH-987654'),
        ],
      ),
    );
  }

  Widget _headerRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: PTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: PTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.add_circle_outline),
        label: Text('Add Item to Bill'),
        style: OutlinedButton.styleFrom(
          foregroundColor: PColors.primaryColor,
          side: BorderSide(color: PColors.primaryColor, width: 1.5),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildItemsCard(List<_BillingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColors.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: PColors.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (idx != 0) Divider(height: 1, color: PColors.lightGray),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: PTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: PColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '₹${item.price.toStringAsFixed(2)} per item',
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
                          color: PColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'x${item.quantity}',
                          style: PTextStyles.labelLarge,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: PTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: PColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(double subtotal, double tax, double total) {
    Widget totalRow(String label, String value, {bool bold = false}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: PTextStyles.bodySmall.copyWith(
                color: PColors.darkGray.withOpacity(0.8),
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: PTextStyles.bodyMedium.copyWith(
                color: bold ? PColors.primaryColor : PColors.darkGray,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                fontSize: bold ? 18 : 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColors.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: PColors.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          totalRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          totalRow('Tax (5%)', '₹${tax.toStringAsFixed(2)}'),
          Divider(height: 24, color: PColors.lightGray),
          totalRow('Total', '₹${total.toStringAsFixed(2)}', bold: true),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: PColors.primaryColor),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: PTextStyles.bodyMedium.copyWith(
                color: PColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.check, color: Colors.white),
            label: Text(
              'Confirm Amount',
              style: PTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class _BillingItem {
  final String name;
  final double price;
  final int quantity;
  const _BillingItem({required this.name, required this.price, required this.quantity});
}