import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/config/routes/app_pages.dart';
import 'app/config/themes/app_theme.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/bindings/AppBinding.dart';
import 'package:get_storage/get_storage.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting('tr_TR', null);
  Get.put(UserController());
  runApp(const RepairShopApp());
}

class RepairShopApp extends StatelessWidget {
  const RepairShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AppBinding(),
      title: 'Project Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.basic,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
