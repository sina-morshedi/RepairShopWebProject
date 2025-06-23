import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
  }
}

