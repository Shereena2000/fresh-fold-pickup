import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/price_item_model.dart';
import '../view_model/price_view.model.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PriceViewModel>(context, listen: false).loadAllCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Manage Price List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF013E6A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF013E6A),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF013E6A),
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Regular'),
            Tab(text: 'Express'),
            Tab(text: 'Premium'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ShopkeeperPriceTable(category: 'regular'),
          ShopkeeperPriceTable(category: 'express'),
          ShopkeeperPriceTable(category: 'premium'),
        ],
      ),
    );
  }
}

class ShopkeeperPriceTable extends StatelessWidget {
  final String category;

  const ShopkeeperPriceTable({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PriceViewModel>(
      builder: (context, priceProvider, child) {
        if (priceProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFF013E6A),
            ),
          );
        }

        return StreamBuilder<List<PriceItemModel>>(
          stream: priceProvider.streamCategoryItems(category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF013E6A),
                ),
              );
            }

            final items = snapshot.data ?? [];

            return Column(
              children: [
                // Add Button
             

                // Items Table
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No items yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap "Add New Item" to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                // Table Header
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF013E6A),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Table(
                                    columnWidths: {
                                      0: FlexColumnWidth(2),
                                      1: FlexColumnWidth(2),
                                      2: FlexColumnWidth(2),
                                      3: FlexColumnWidth(2),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          _buildHeaderCell('Item Name'),
                                          _buildHeaderCell('Dry Wash'),
                                          _buildHeaderCell('Wet Wash'),
                                          _buildHeaderCell('Steam Press'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Table Body
                                Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(2),
                                  },
                                  children: items
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    PriceItemModel item = entry.value;
                                    bool isEven = index % 2 == 0;
                                        return _buildTableRow(
                                          context,
                                          item,
                                          isEven,
                                        );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildTableRow(
    BuildContext context,
    PriceItemModel item,
    bool isEven,
  ) {
    Color bgColor = isEven ? Colors.grey[50]! : Colors.white;

    return TableRow(
      decoration: BoxDecoration(color: bgColor),
      children: [
        // Item Name
        _buildDataCell(
          item.itemName,
          TextAlign.left,
          fontWeight: FontWeight.w600,
          color: Color(0xFF013E6A),
        ),
        // Dry Wash Price
        _buildPriceCell('₹${item.dryWash}', Colors.blue),
        // Wet Wash Price
        _buildPriceCell('₹${item.wetWash}', Colors.green),
        // Steam Press Price
        _buildPriceCell('₹${item.steamPress}', Colors.orange),
      ],
    );
  }

  Widget _buildDataCell(
    String text,
    TextAlign align, {
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: fontWeight,
          color: color ?? Colors.black87,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildPriceCell(String price, MaterialColor color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        price,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

}