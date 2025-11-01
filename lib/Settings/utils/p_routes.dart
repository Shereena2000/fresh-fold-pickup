import 'package:flutter/material.dart';
import 'package:fresh_fold_pickup/Features/wrapper/view/ui.dart';

import '../../Features/add_billing/view/ui.dart';
import '../../Features/auth/view/sigin.dart';
import '../../Features/auth/view/sign_up.dart';
import '../../Features/delivery/view/ui.dart';
import '../../Features/direction_screen/view/ui.dart';
import '../../Features/earnings/view/ui.dart';
import '../../Features/order_detail/ui.dart';
import '../../Features/splash_screen/view/ui.dart';
import '../../Features/home/view_model/home_view_model.dart';
import 'p_pages.dart';

class Routes {
  static Route<dynamic>? genericRoute(RouteSettings settings) {
    switch (settings.name) {
      case PPages.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());
              case PPages.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());
              case PPages.signUp:
        return MaterialPageRoute(builder: (context) => SignUpScreen());
             case PPages.wrapperPageUi:
        return MaterialPageRoute(builder: (context) => WrapperScreen());
      case PPages.orderDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final orderData = args['orderData'] as OrderCardData;
        return MaterialPageRoute(
          builder: (context) => OrderDetailScreen(orderData: orderData),
        );
      case PPages.directions:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => DirectionScreen(
            destinationAddress: args['destinationAddress'] as String,
          ),
        );
      case PPages.billing:
        return MaterialPageRoute(
          builder: (context) => BillingScreen(),
        );
      case PPages.delivery:
        return MaterialPageRoute(
          builder: (context) => DeliveryScreen(),
        );
      case PPages.earnings:
        return MaterialPageRoute(
          builder: (context) => EarningsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Page Not Found')),
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }
}
