
import 'package:repair_shop_web/app/features/dashboard/controllers/insertcarinfo_controller.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/reports_controller.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/settings_controller.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/troubleshooting_controller.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/project_manage_controller.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/dashboard_controller.dart';

import 'package:get/get.dart';
// part 'insertcarinfo_binding.dart';
// part 'project_manage_binding.dart';
// part 'reports_binding.dart';
// part 'settings_binding.dart';
// part 'dashboard_binding.dart';
// part 'troubleshooting_binding.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController(), permanent: true);
    Get.put(InsertcarinfoController(), permanent: true);
    Get.put(ProjectManageController(), permanent: true);
    Get.put(ReportsController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(TroubleshootingController(), permanent: true);
    Get.put(UserController(), permanent: true);
  }
}