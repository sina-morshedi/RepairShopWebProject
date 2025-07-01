import 'package:repair_shop_web/app/features/dashboard/controllers/troubleshooting_controller.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
class ProjectManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProjectManageController());
  }
}

