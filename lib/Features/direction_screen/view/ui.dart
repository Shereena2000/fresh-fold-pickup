import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_text_styles.dart';

import '../view_model/direction_view_model.dart';

class DirectionScreen extends StatelessWidget {
  final String destinationAddress; // customer pickup address
  const DirectionScreen({super.key, required this.destinationAddress});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DirectionViewModel()..initWithAddress(destinationAddress),
      child: Consumer<DirectionViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Directions'),
            body: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: vm.initialCameraPosition,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: vm.markers,
                  polylines: vm.polylines,
                  onMapCreated: (controller) {
                    if (!vm.mapController.isCompleted) {
                      vm.mapController.complete(controller);
                    }
                  },
                ),
                if (vm.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(PColors.primaryColor),
                        ),
                      ),
                    ),
                  ),
                if (vm.errorMessage != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PColors.errorRed,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  vm.errorMessage!,
                                  style: PTextStyles.bodyMedium.copyWith(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.white, size: 20),
                                onPressed: () => vm.clearError(),
                              ),
                            ],
                          ),
                          if (vm.errorMessage!.contains('internet') || vm.errorMessage!.contains('Failed'))
                            Padding(
                              padding: EdgeInsets.only(top: 12, left: 36),
                              child: ElevatedButton.icon(
                                onPressed: vm.isLoading ? null : () => vm.retryGeocode(),
                                icon: Icon(Icons.refresh, size: 18),
                                label: Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: PColors.errorRed,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                // Destination info card
                if (vm.destination != null && !vm.isLoading)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: PColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: PColors.primaryColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Destination',
                                  style: PTextStyles.bodySmall.copyWith(
                                    color: PColors.darkGray.withOpacity(0.6),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  vm.addressLabel ?? 'Pickup Address',
                                  style: PTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: PColors.darkGray,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Bottom action buttons
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: vm.isLoading
                              ? null
                              : () => context.read<DirectionViewModel>().useCurrentLocationAsStart(),
                          icon: Icon(Icons.my_location, color: Colors.white),
                          label: Text(
                            'Use Current Location',
                            style: PTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: vm.origin == null || vm.destination == null
                              ? null
                              : () => context.read<DirectionViewModel>().startNavigation(),
                          icon: Icon(Icons.directions, color: Colors.white),
                          label: Text(
                            'Start Navigation',
                            style: PTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vm.origin != null && vm.destination != null
                                ? PColors.successGreen
                                : PColors.lightGray,
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}