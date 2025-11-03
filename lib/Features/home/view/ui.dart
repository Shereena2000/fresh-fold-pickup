import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_fold_pickup/Features/home/view/widgets/today_widgets.dart';
import 'package:fresh_fold_pickup/Features/home/view/widgets/upcoming_widget.dart';
import 'package:fresh_fold_pickup/Features/home/view_model/home_view_model.dart';
import 'package:fresh_fold_pickup/Settings/common/widgets/custom_tab_section.dart';
import 'package:fresh_fold_pickup/Settings/constants/sized_box.dart';
import 'package:fresh_fold_pickup/Settings/utils/p_colors.dart';

import '../../../Settings/common/widgets/custom_app_bar.dart';

// Tab configuration for HomeScreen
final List<String> tabTitles = ['Today', 'Upcoming'];

final List<Widget> tabContents = [
  // Today tab content
  TodayWidgets(),
  UpcomingWidget(),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load orders when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Orders'),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<HomeViewModel>().refreshOrders();
        },
        color: PColors.primaryColor,
        child: Column(
          children: [
            SizeBoxH(16),
            Expanded(
              child: CustomTabSection(
                tabTitles: tabTitles,
                tabContents: tabContents,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
