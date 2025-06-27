import 'package:repair_shop_web/app/features/dashboard/views/screens/insert_car_info_screen.dart';

import 'package:repair_shop_web/app/features/dashboard/views/screens/dashboard_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/login_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/bindings/dashboard_binding.dart';
import 'package:repair_shop_web/app/features/dashboard/bindings/insertcarinfo_binding.dart';
import 'package:repair_shop_web/app/features/dashboard/bindings/settings_binding.dart';
import 'package:repair_shop_web/app/features/dashboard/bindings/troubleshooting_binding.dart';
import 'package:get/get.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/settings_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/troubleshooting_screen.dart';

part 'app_routes.dart';

/// contains all configuration pages
class AppPages {
  /// when the app is opened, this page will be the first to be shown
  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: _Paths.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.insertCarInfo,
      page: () => const InsertCarInfoScreen(),
      binding: InsertcarinfoBinding(),
    ),
    GetPage(
      name: _Paths.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.troubleshooting,
      page: () => const TroubleshootingScreen(),
      binding: TroubleshootingBinding(),
    ),
  ];
}
