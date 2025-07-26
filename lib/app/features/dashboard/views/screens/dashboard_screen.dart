import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import '../../../../shared_components/TaskFlowManager.dart';  // مسیر درست را تنظیم کن
// import ویجت کارت پروگرس اگر جداست:
// import 'path_to_progress_report_card.dart';

class DashboardScreen extends GetView<DashboardController> {
  DashboardScreen({Key? key}) : super(key: key);

  // کلید برای دسترسی به State داخل TaskFlowManager
  final GlobalKey<TaskFlowManagerState> taskFlowKey = GlobalKey<TaskFlowManagerState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initTaskStatusCounts(context);
    });

    // وقتی کاربر سرچ می‌کند، مقدار را به TaskFlowManager ارسال کن
    void onSearchHandler(String plate) {
      taskFlowKey.currentState?.triggerSearch(plate, context);
    }

    return SingleChildScrollView(
      child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) {
          return Column(
            children: [
              const SizedBox(height: kSpacing),
              _buildHeader(onSearch: onSearchHandler),
              const SizedBox(height: kSpacing),
              _buildProgressCard(),
              const SizedBox(height: kSpacing),
              TaskFlowManager(controller: controller, key: taskFlowKey),
            ],
          );
        },
        tabletBuilder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: (constraints.maxWidth < 950) ? 6 : 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing),
                    _buildHeader(onSearch: onSearchHandler),
                    const SizedBox(height: kSpacing),
                    _buildProgressCard(),
                    const SizedBox(height: kSpacing),
                    TaskFlowManager(controller: controller, key: taskFlowKey),
                  ],
                ),
              ),
            ],
          );
        },
        desktopBuilder: (context, constraints) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: (constraints.maxWidth < 1360) ? 4 : 3,
                  child: Container(
                    color: Colors.grey[200],
                  ),
                ),
                Flexible(
                  flex: 9,
                  child: Column(
                    children: [
                      const SizedBox(height: kSpacing * 2),
                      _buildHeader(onSearch: onSearchHandler),
                      const SizedBox(height: kSpacing),
                      _buildProgressCard(),
                      const SizedBox(height: kSpacing),
                      TaskFlowManager(controller: controller, key: taskFlowKey),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader({Function(String value)? onSearch}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Header(onSearchSubmit: onSearch),
    );
  }

  Widget _buildProgressCard() {
    return Obx(() {
      final undoneToCount = ["GİRMEK", "SORUN GİDERME", "USTA"];
      final totalUndone = controller.taskStatusCounts
          .where((e) => undoneToCount.contains(e.taskStatusName))
          .fold<int>(0, (sum, e) => sum + e.count);

      final inProgressToCount = ["BAŞLANGIÇ", "DURAKLAT"];
      final totalInProgress = controller.taskStatusCounts
          .where((e) => inProgressToCount.contains(e.taskStatusName))
          .fold<int>(0, (sum, e) => sum + e.count);

      final doneToCount = ["İŞ BİTTİ", "FATURA"];
      final totalDone = controller.taskStatusCounts
          .where((e) => doneToCount.contains(e.taskStatusName))
          .fold<int>(0, (sum, e) => sum + e.count);

      final totalTasks = totalUndone + totalInProgress + totalDone;
      final percentDone = totalTasks > 0
          ? double.parse(((totalInProgress / totalTasks) * 100).toStringAsFixed(1))
          : 0.0;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpacing),
        child: ProgressReportCard(
          data: ProgressReportCardData(
            title: "Sprint Status",
            doneTask: totalDone,
            percent: percentDone / 100,
            task: totalTasks,
            undoneTask: totalUndone,
            inProgressTask: totalInProgress,
          ),
        ),
      );
    });
  }
}
