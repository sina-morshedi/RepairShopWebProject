import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_storage/get_storage.dart';

import 'app/config/routes/app_pages.dart';
import 'app/config/themes/app_theme.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/features/dashboard/bindings/AppBinding.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  // آماده‌سازی اطلاعات محلی ترکی استانبولی
  await initializeDateFormatting('tr_TR', null);

  // ثبت کنترلر گلوبال
  Get.put(UserController());
  tz.initializeTimeZones();
  // اجرای اپ
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

      // 👇 تنظیم زبان اپلیکیشن
      locale: const Locale('tr'), // ترکی استانبولی

      // 👇 پشتیبانی از لوکال‌ها
      supportedLocales: const [
        Locale('tr'), // ترکی
        Locale('en'), // انگلیسی (اختیاری)
      ],

      // 👇 فعال‌سازی محلی‌سازی ویجت‌ها مثل DatePicker
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
