import 'package:repair_shop_web/app/features/dashboard/views/screens/insert_car_info_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/dashboard_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/login_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/settings_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/troubleshooting_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/reports_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/project_manage_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/invoice_screen.dart';
import 'package:repair_shop_web/app/features/dashboard/views/screens/main_layout.dart';

import 'package:get/get.dart';

import 'package:repair_shop_web/app/features/dashboard/bindings/AppBinding.dart';
import 'package:repair_shop_web/app/shared_components/InvoiceForm.dart';
import 'package:repair_shop_web/app/shared_components/CustomerForm.dart';
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
      page: () => MainLayout(child: DashboardScreen()),

    ),
    GetPage(
      name: _Paths.insertCarInfo,
      page: () => MainLayout(child: InsertCarInfoScreen()),

    ),
    GetPage(
      name: _Paths.settings,
      page: () => MainLayout(child: SettingsScreen()),

    ),
    GetPage(
      name: _Paths.troubleshooting,
      page: () => MainLayout(child: TroubleshootingScreen()),

    ),
    GetPage(
      name: _Paths.reports,
      page: () => MainLayout(child: ReportsScreen()),

    ),
    GetPage(
      name: _Paths.projectManage,
      page: () => MainLayout(child: ProjectManageScreen()),
    ),
    GetPage(
      name: _Paths.fatura,
      page: () => MainLayout(child: InvoiceForm()),
    ),
    GetPage(
      name: _Paths.customerInfo,
      page: () => MainLayout(child: CustomerForm()),
    ),
  ];
}
