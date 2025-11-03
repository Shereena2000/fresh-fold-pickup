import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';
import 'package:provider/provider.dart';
import '../../home/view_model/home_view_model.dart';
import '../../PriceList/view_model/price_view.model.dart';
import '../view_model/billing_view_model.dart';
import '../model/billing_item.dart';

class BillingScreen extends StatefulWidget {
  final OrderCardData? orderData;

  const BillingScreen({super.key, this.orderData});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeBilling();
  }

  Future<void> _initializeBilling() async {
    if (widget.orderData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No order data provided'),
            backgroundColor: PColors.errorRed,
          ),
        );
        Navigator.pop(context);
      });
      return;
    }

    final billingViewModel = context.read<BillingViewModel>();
    final priceViewModel = context.read<PriceViewModel>();

    billingViewModel.setOrderData(widget.orderData!);

    // Load price items for the service type
    await priceViewModel.loadCategoryItems(
      widget.orderData!.schedule.serviceType.toLowerCase(),
    );

    final items = priceViewModel.getItemsForCategory(
      widget.orderData!.schedule.serviceType.toLowerCase(),
    );

    // Initialize billing items
    billingViewModel.initializeBillingItems(
      items,
      widget.orderData!.schedule.washType,
    );

    // Load existing billing if any
    await billingViewModel.loadBillingDetails(
      widget.orderData!.schedule.userId,
      widget.orderData!.schedule.scheduleId,
    );
    
    // If billing exists, populate the items with existing quantities
    if (billingViewModel.currentBilling != null) {
      final existingItems = billingViewModel.currentBilling!.items;
      for (var existingItem in existingItems) {
        final index = billingViewModel.billingItems.indexWhere(
          (item) => item.priceItem.itemId == existingItem.itemId,
        );
        if (index != -1) {
          billingViewModel.updateQuantity(index, existingItem.quantity);
        }
      }
    }

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Billing'),
        body: Center(
          child: CircularProgressIndicator(color: PColors.primaryColor),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Billing'),
      body: Consumer<BillingViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                _buildHeaderCard(viewModel),
            SizedBox(height: 16),
                _buildAddItemButton(viewModel),
            SizedBox(height: 16),
                _buildItemsCard(viewModel),
            SizedBox(height: 16),
                _buildTotalsCard(viewModel),
            SizedBox(height: 24),
                _buildActionButtons(viewModel),
          ],
        ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BillingViewModel viewModel) {
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
          _headerRow('Customer', viewModel.orderData?.customerName ?? 'N/A'),
          _headerRow('Service Type', _formatServiceType(viewModel.orderData?.schedule.serviceType ?? '')),
          _headerRow('Wash Type', _formatWashType(viewModel.orderData?.schedule.washType ?? '')),
          _headerRow('Schedule ID', viewModel.orderData?.orderId ?? 'N/A'),
        ],
      ),
    );
  }
  
  String _formatServiceType(String type) {
    switch (type.toLowerCase()) {
      case 'regular':
        return 'Regular';
      case 'express':
        return 'Express';
      case 'premium':
        return 'Premium';
      default:
        return type;
    }
  }

  String _formatWashType(String type) {
    switch (type.toLowerCase()) {
      case 'dry_clean':
        return 'Dry Cleaning & Steam Press';
      case 'wash_press':
        return 'Wash & Steam Press';
      case 'press_only':
        return 'Steam Press Only';
      default:
        return type;
    }
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

  Widget _buildAddItemButton(BillingViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddItemDialog(viewModel),
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

  void _showAddItemDialog(BillingViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemBottomSheet(viewModel: viewModel),
    );
  }

  Widget _buildItemsCard(BillingViewModel viewModel) {
    final addedItems = viewModel.addedItems;

    if (addedItems.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PColors.lightGray, width: 1.5),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
              SizedBox(height: 12),
              Text(
                'No items added yet',
                style: PTextStyles.bodyMedium.copyWith(color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                'Tap "Add Item to Bill" to get started',
                style: PTextStyles.bodySmall.copyWith(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      );
    }

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
          ...addedItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final originalIndex = viewModel.billingItems.indexOf(item);
            
            return Column(
              children: [
                if (idx != 0) Divider(height: 1, color: PColors.lightGray),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.priceItem.itemName,
                              style: PTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: PColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '₹${item.unitPrice.toStringAsFixed(2)} per item',
                              style: PTextStyles.bodySmall.copyWith(
                                color: PColors.darkGray.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          color: PColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, size: 18),
                              onPressed: () => viewModel.updateQuantity(originalIndex, item.quantity - 1),
                              color: PColors.primaryColor,
                              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                            Container(
                              constraints: BoxConstraints(minWidth: 30),
                              alignment: Alignment.center,
                        child: Text(
                                '${item.quantity}',
                                style: PTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: PColors.primaryColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, size: 18),
                              onPressed: () => viewModel.updateQuantity(originalIndex, item.quantity + 1),
                              color: PColors.primaryColor,
                              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '₹${item.itemTotal.toStringAsFixed(2)}',
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

  Widget _buildTotalsCard(BillingViewModel viewModel) {
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
          totalRow('Total Amount', '₹${viewModel.totalAmount.toStringAsFixed(2)}', bold: true),
          SizedBox(height: 8),
          Text(
            '${viewModel.addedItems.length} items',
            style: PTextStyles.bodySmall.copyWith(
              color: PColors.darkGray.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BillingViewModel viewModel) {
    final paymentStatus = viewModel.paymentStatus;
    final isPaymentSet = viewModel.isPaymentSet;
    
    // Determine button state based on payment status
    String buttonText;
    Color? buttonColor;
    bool isDisabled = false;
    IconData buttonIcon;
    
    if (isPaymentSet) {
      switch (paymentStatus) {
        case 'pay_request':
          buttonText = 'Payment Request Sent';
          buttonColor = Colors.orange;
          buttonIcon = Icons.pending;
          isDisabled = true;
          break;
        case 'paid':
          buttonText = 'Payment Completed ✓';
          buttonColor = PColors.successGreen;
          buttonIcon = Icons.check_circle;
          isDisabled = true;
          break;
        case 'cancelled':
          buttonText = 'Payment Cancelled';
          buttonColor = PColors.errorRed;
          buttonIcon = Icons.block;
          isDisabled = true;
          break;
        default:
          buttonText = 'Update Payment Request';
          buttonColor = PColors.primaryColor;
          buttonIcon = Icons.update;
          isDisabled = false;
      }
    } else {
      buttonText = 'Send Payment Request';
      buttonColor = PColors.primaryColor;
      buttonIcon = Icons.send;
      isDisabled = false;
    }

    return Column(
      children: [
        // Show payment status if exists
        if (isPaymentSet)
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _getStatusColor(paymentStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(paymentStatus),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(paymentStatus), color: _getStatusColor(paymentStatus)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: PColors.darkGray.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getStatusText(paymentStatus),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(paymentStatus),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${viewModel.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _getStatusColor(paymentStatus),
                  ),
                ),
              ],
            ),
          ),
        
        Row(
      children: [
        Expanded(
          child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: PColors.primaryColor),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
                  isPaymentSet ? 'Close' : 'Cancel',
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
                onPressed: (viewModel.addedItems.isEmpty || viewModel.isSaving || isDisabled)
                    ? null
                    : () => _handleConfirmPayment(viewModel),
                icon: viewModel.isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(buttonIcon, color: Colors.white, size: 20),
            label: Text(
                  viewModel.isSaving ? 'Sending...' : buttonText,
              style: PTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                    fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  disabledBackgroundColor: PColors.lightGray,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
            ),
          ],
        ),
      ],
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pay_request':
        return Colors.orange;
      case 'paid':
        return PColors.successGreen;
      case 'cancelled':
        return PColors.errorRed;
      default:
        return PColors.primaryColor;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pay_request':
        return Icons.pending;
      case 'paid':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.payment;
    }
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'pay_request':
        return 'Payment Request Sent';
      case 'paid':
        return 'Payment Completed';
      case 'cancelled':
        return 'Payment Cancelled';
      default:
        return 'Pending';
    }
  }

  Future<void> _handleConfirmPayment(BillingViewModel viewModel) async {
    if (viewModel.orderData == null) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Payment Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${viewModel.orderData!.orderId}'),
            SizedBox(height: 8),
            Text('Total Items: ${viewModel.addedItems.length}'),
            SizedBox(height: 8),
            Text(
              'Total Amount: ₹${viewModel.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PColors.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This will send a payment request to the customer.',
              style: TextStyle(fontSize: 13, color: PColors.darkGray),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Save billing
    final success = await viewModel.saveBillingDetails(
      userId: viewModel.orderData!.schedule.userId,
      scheduleId: viewModel.orderData!.schedule.scheduleId,
      serviceType: viewModel.orderData!.schedule.serviceType,
      washType: viewModel.orderData!.schedule.washType,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment request sent successfully!'),
          backgroundColor: PColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to send payment request'),
          backgroundColor: PColors.errorRed,
        ),
      );
    }
  }
}

// Bottom sheet for adding items
class _AddItemBottomSheet extends StatefulWidget {
  final BillingViewModel viewModel;

  const _AddItemBottomSheet({required this.viewModel});

  @override
  State<_AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<_AddItemBottomSheet> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<int, BillingItem>> get filteredItems {
    final entries = widget.viewModel.billingItems.asMap().entries.toList();
    if (searchQuery.isEmpty) return entries;

    return entries.where((entry) {
      return entry.value.priceItem.itemName.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingViewModel>(
      builder: (context, viewModel, child) {
        final filteredList = filteredItems;

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Item',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: PColors.primaryColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: PColors.darkGray,
                        ),
                      ],
                    ),
                  ),
                  
                  // Search bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search items...',
                        prefixIcon: Icon(Icons.search, color: PColors.primaryColor),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: PColors.scaffoldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  Divider(height: 1),
                  
                  // Items list
                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                                SizedBox(height: 16),
                                Text(
                                  searchQuery.isEmpty
                                      ? 'No items available'
                                      : 'No items match "$searchQuery"',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: filteredList.length,
                            itemBuilder: (context, listIndex) {
                              final entry = filteredList[listIndex];
                              final index = entry.key;
                              final item = entry.value;
                              final isAdded = item.quantity > 0;

                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isAdded ? PColors.primaryColor.withOpacity(0.08) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isAdded
                                        ? PColors.primaryColor.withOpacity(0.3)
                                        : PColors.lightGray,
                                    width: 1.5,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  title: Text(
                                    item.priceItem.itemName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: PColors.primaryColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '₹${item.unitPrice.toStringAsFixed(2)} per item',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: PColors.darkGray.withOpacity(0.6),
                                    ),
                                  ),
                                  trailing: isAdded
                                      ? Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: PColors.primaryColor,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check, size: 16, color: Colors.white),
                                              SizedBox(width: 4),
                                              Text(
                                                'Added (${item.quantity})',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Icon(Icons.add_circle_outline, color: PColors.primaryColor),
                                  onTap: () {
                                    if (isAdded) {
                                      widget.viewModel.updateQuantity(index, item.quantity + 1);
                                    } else {
                                      widget.viewModel.updateQuantity(index, 1);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}