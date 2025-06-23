import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
class InsertcarinfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InsertcarinfoController());
  }
}

