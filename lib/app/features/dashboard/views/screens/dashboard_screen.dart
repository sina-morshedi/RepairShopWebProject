library dashboard;

import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initTaskStatusCounts(context);

    });
    return SingleChildScrollView(
      child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) {
          return Column(
            children: [
              const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
              _buildProgress(axis: Axis.vertical),
              const SizedBox(height: kSpacing),

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
                    const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
                    _buildProgress(
                      axis: (constraints.maxWidth < 950)
                          ? Axis.vertical
                          : Axis.horizontal,
                    ),
                    const SizedBox(height: kSpacing * 2),

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
                    color: Colors.grey[200], // فقط برای دیدن ارتفاع سایدبار
                  ),
                ),
                Flexible(
                  flex: 9,
                  child: Column(
                    children: [
                      const SizedBox(height: kSpacing),
                      _buildProgress(axis: (constraints.maxWidth < 950)
                          ? Axis.vertical
                          : Axis.horizontal,
                      ),
                      const SizedBox(height: kSpacing * 2),
                      // بقیه ویجت‌ها...
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

  Widget _buildHeader({Function()? onPressedMenu}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Row(
        children: [
          if (onPressedMenu != null)
            Padding(
              padding: const EdgeInsets.only(right: kSpacing),
              child: IconButton(
                onPressed: onPressedMenu,
                icon: const Icon(EvaIcons.menu),
                tooltip: "menu",
              ),
            ),
          const Expanded(child: Header()),
        ],
      ),
    );
  }

  Widget _buildProgress({Axis axis = Axis.horizontal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Obx(() {
        final undoneToCount = ["GİRMEK", "SORUN GİDERME", "ÜSTA"];

        final totalUndone = controller.taskStatusCounts
            .where((e) => undoneToCount.contains(e.taskStatusName))
            .fold<int>(0, (sum, e) => sum + e.count);


        final inProgressToCount = ["BAŞLANGIÇ", "DURAKLAT"];

        int totalInProgress = controller.taskStatusCounts
            .where((e) => inProgressToCount.contains(e.taskStatusName))
            .fold<int>(0, (sum, e) => sum + e.count);

        final doneToCount = ["İŞ BİTTİ", "FATURA"];
        int totalDone = controller.taskStatusCounts
            .where((e) => doneToCount.contains(e.taskStatusName))
            .fold<int>(0, (sum, e) => sum + e.count);

        final totalTasks = totalUndone + totalInProgress + totalDone;
        final percentDone = totalTasks > 0
            ? double.parse(((totalInProgress / totalTasks) * 100).toStringAsFixed(1))
            : 0.0;

        if (axis == Axis.horizontal) {
          return Row(
            children: [
              Flexible(
                flex: 5,
                child: ProgressCard(
                  data: ProgressCardData(
                    totalUndone: totalUndone,
                    totalTaskInProress: totalInProgress,
                  ),
                  onPressedCheck: () {},
                ),
              ),
              const SizedBox(width: kSpacing / 2),
              Flexible(
                flex: 4,
                child: ProgressReportCard(
                  data: ProgressReportCardData(
                    title: "Sprint Status",
                    doneTask: totalDone,
                    percent: percentDone/100,
                    task: totalTasks,
                    undoneTask: totalUndone,
                    inProgressTask: totalInProgress
                  ),
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              ProgressCard(
                data: ProgressCardData(
                  totalUndone: totalUndone,
                  totalTaskInProress: totalInProgress,
                ),
                onPressedCheck: () {},
              ),
              const SizedBox(height: kSpacing / 2),
              ProgressReportCard(
                data: ProgressReportCardData(
                  title: "Sprint Status",
                  doneTask: totalDone,
                  percent: percentDone/100,
                  task: totalTasks,
                  undoneTask: totalUndone,
                  inProgressTask: totalInProgress
                ),
              ),
            ],
          );
        }
      }),
    );
  }

}
