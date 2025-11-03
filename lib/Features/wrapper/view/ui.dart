import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Features/PriceList/view/ui.dart';

import 'package:provider/provider.dart';

import '../../../Settings/utils/p_colors.dart';
import '../../home/view/ui.dart';
import '../../delivery/view/ui.dart';
import '../../profile/view/ui.dart';
import '../../menu/menu_screen.dart';
import '../view_model/navigation_provider.dart';

class WrapperScreen extends StatefulWidget {
  WrapperScreen({super.key});

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  @override
  void initState() {
    super.initState();
    // Always reset to home screen when wrapper is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().resetIndex();
    });
  }

  final List<Widget> _pages = [
    HomeScreen(), 
    DeliveryScreen(), 
    PriceListScreen(), 
    ProfileScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final List<NavItem> navItems = [
      NavItem(icon: Icons.home, label: 'Home'),
      NavItem(icon: Icons.delivery_dining, label: 'My Deliveries'),
      NavItem(icon: Icons.list_alt, label: 'Price List'),
      NavItem(icon: Icons.person, label: 'Profile'),
      NavItem(icon: Icons.menu, label: 'Menu'),
    ];

    return Scaffold(
      body: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return _pages[navigationProvider.selectedIndex];
        },
      ),
      bottomNavigationBar: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: PColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(navItems.length, (index) {
                final isSelected = navigationProvider.selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    navigationProvider.setSelectedIndex(index);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: isSelected ? 15 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PColors.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          navItems[index].icon,
                          color: isSelected ? PColors.white : PColors.black,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 8),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.0,
                            child: Text(
                              navItems[index].label,
                              style: TextStyle(
                                color: PColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}
