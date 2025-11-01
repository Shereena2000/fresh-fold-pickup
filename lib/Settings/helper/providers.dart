

import 'package:fresh_fold_pickup/Features/auth/view_model.dart/auth_view_model.dart';
import 'package:fresh_fold_pickup/Features/home/view_model/home_view_model.dart';
import 'package:fresh_fold_pickup/Features/PriceList/view_model/price_view.model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../Features/wrapper/view_model/navigation_provider.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => AuthViewModel()),
  ChangeNotifierProvider(create: (_) => NavigationProvider()),
  ChangeNotifierProvider(create: (_) => PriceViewModel()),
  ChangeNotifierProvider(create: (_) => HomeViewModel()),
];
