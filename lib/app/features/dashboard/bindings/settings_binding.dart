import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}

