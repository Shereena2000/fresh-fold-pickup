import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_fold_pickup/Features/home/view/widgets/today_widgets.dart';
import 'package:fresh_fold_pickup/Features/home/view/widgets/upcoming_widget.dart';
import 'package:fresh_fold_pickup/Features/home/view_model/home_view_model.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_tab_section.dart';
import 'package:fresh_fold_pickup/Settings/constants/sized_box.dart';

import '../../../Settings/common/widgets/custom_app_bar.dart';

// Tab configuration for HomeScreen
final List<String> tabTitles = ['Today', 'Upcoming'];

final List<Widget> tabContents = [
  // Today tab content
  TodayWidgets(),
  UpcomingWidget(),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load orders when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadOrders();
    });

    return Scaffold(
      appBar: CustomAppBar(title: 'Orders'),
      body: Column(
        children: [
          SizeBoxH(16),
          Expanded(
            child: CustomTabSection(tabTitles: tabTitles, tabContents: tabContents),
          ),
        ],
      ),
    );
  }
}
