import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_tab_section.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_pages.dart';
import 'package:fresh_fold_pickup/Settings/utils/call_utils.dart';
import 'package:provider/provider.dart';
import '../../auth/view_model.dart/auth_view_model.dart';
import '../../home/view/widgets/order_card.dart';
import '../view_model/delivery_view_model.dart';

// Tab configuration
final List<String> deliveryTabTitles = ['Active', 'Completed'];

final List<Widget> deliveryTabContents = [
  ActiveDeliveryWidget(),
  CompletedDeliveryWidget(),
];

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  @override
  void initState() {
    super.initState();
    // Load deliveries when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final deliveryViewModel = context.read<DeliveryViewModel>();
      
      if (authViewModel.currentVendor != null) {
        deliveryViewModel.setDriverId(authViewModel.currentVendor!.uid);
        deliveryViewModel.loadMyDeliveries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'My Deliveries'),
      body: Column(
        children: [
          // Search Bar
          Consumer<DeliveryViewModel>(
            builder: (context, viewModel, child) {
              return Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  onChanged: (value) {
                    viewModel.updateSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name or order ID...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: PColors.primaryColor),
                    suffixIcon: viewModel.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              viewModel.clearSearch();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: PColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              );
            },
          ),
          
          // Tabs Section
          Expanded(
            child: CustomTabSection(
              tabTitles: deliveryTabTitles,
              tabContents: deliveryTabContents,
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveDeliveryWidget extends StatelessWidget {
  const ActiveDeliveryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: PColors.primaryColor,
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading deliveries...',
                  style: TextStyle(
                    color: PColors.darkGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.refreshDeliveries(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final activeDeliveries = viewModel.activeDeliveries;

        // ✅ Wrap with RefreshIndicator for pull-to-refresh
        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.refreshDeliveries();
          },
          color: PColors.primaryColor,
          backgroundColor: Colors.white,
          strokeWidth: 3.0,
          displacement: 40.0,
          child: activeDeliveries.isEmpty
              ? ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      viewModel.searchQuery.isNotEmpty 
                          ? Icons.search_off 
                          : Icons.delivery_dining,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      viewModel.searchQuery.isNotEmpty
                          ? 'No results found'
                          : 'No active deliveries',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      viewModel.searchQuery.isNotEmpty
                          ? 'Try a different search term'
                          : 'Take orders from the Home screen',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                    if (viewModel.searchQuery.isEmpty) ...[
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, size: 16, color: PColors.primaryColor),
                          SizedBox(width: 6),
                          Text(
                            'Pull down to refresh',
                            style: TextStyle(
                              color: PColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: activeDeliveries.length,
                    itemBuilder: (context, index) {
              final orderData = activeDeliveries[index];

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
                  await Navigator.pushNamed(
                    context,
                    PPages.orderDetail,
                    arguments: {
                      'orderData': orderData,
                    },
                  );
                  
                  // Refresh after returning
                  if (context.mounted) {
                    viewModel.refreshDeliveries();
                  }
                },
              );
            },
          ),
        ),
        );
      },
    );
  }
}

class CompletedDeliveryWidget extends StatelessWidget {
  const CompletedDeliveryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: PColors.primaryColor),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.refreshDeliveries(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final completedDeliveries = viewModel.completedDeliveries;

        // ✅ Wrap with RefreshIndicator for pull-to-refresh
        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.refreshDeliveries();
          },
          color: PColors.primaryColor,
          backgroundColor: Colors.white,
          strokeWidth: 3.0,
          displacement: 40.0,
          child: completedDeliveries.isEmpty
              ? ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      viewModel.searchQuery.isNotEmpty 
                          ? Icons.search_off 
                          : Icons.check_circle_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      viewModel.searchQuery.isNotEmpty
                          ? 'No results found'
                          : 'No completed deliveries',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    viewModel.searchQuery.isNotEmpty
                        ? Text(
                            'Try a different search term',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, size: 16, color: PColors.primaryColor),
                              SizedBox(width: 6),
                              Text(
                                'Pull down to refresh',
                                style: TextStyle(
                                  color: PColors.primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: completedDeliveries.length,
                    itemBuilder: (context, index) {
              final orderData = completedDeliveries[index];

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
                  await Navigator.pushNamed(
                    context,
                    PPages.orderDetail,
                    arguments: {
                      'orderData': orderData,
                    },
                  );
                  
                  // Refresh after returning
                  if (context.mounted) {
                    viewModel.refreshDeliveries();
                  }
                },
              );
            },
          ),
        ),
        );
      },
    );
  }
}

