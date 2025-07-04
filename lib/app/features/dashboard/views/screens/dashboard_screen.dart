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
              _buildTaskOverview(
                data: controller.getAllTask(),
                headerAxis: Axis.vertical,
                crossAxisCount: 6,
                crossAxisCellCount: 6,
              ),
              // بقیه ویجت‌های داشبورد اینجا ...
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
                    _buildTaskOverview(
                      data: controller.getAllTask(),
                      headerAxis: (constraints.maxWidth < 850)
                          ? Axis.vertical
                          : Axis.horizontal,
                      crossAxisCount: 6,
                      crossAxisCellCount: (constraints.maxWidth < 950)
                          ? 6
                          : (constraints.maxWidth < 1100)
                          ? 3
                          : 2,
                    ),
                    // بقیه ویجت‌ها...
                  ],
                ),
              ),
            ],
          );
        },
        desktopBuilder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: (constraints.maxWidth < 1360) ? 4 : 3,
                child: const SizedBox.shrink(), // حذف Sidebar از اینجا
              ),
              Flexible(
                flex: 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing),
                    _buildProgress(),
                    const SizedBox(height: kSpacing * 2),
                    _buildTaskOverview(
                      data: controller.getAllTask(),
                      crossAxisCount: 6,
                      crossAxisCellCount: (constraints.maxWidth < 1360) ? 3 : 2,
                    ),
                    // بقیه ویجت‌ها...
                  ],
                ),
              ),
            ],
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

        final totalDone = controller.taskStatusCounts
            .where((e) => e.taskStatusName == 'SON')
            .fold<int>(0, (sum, e) => sum + e.count);

        // final totalTasks = totalUndone + totalInProgress + totalDone;
        final totalTasks = 7;
        totalInProgress = 1;
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


  Widget _buildTaskOverview({
    required List<TaskCardData> data,
    int crossAxisCount = 6,
    int crossAxisCellCount = 2,
    Axis headerAxis = Axis.horizontal,
  }) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: crossAxisCount,
      itemCount: data.length + 1,
      addAutomaticKeepAlives: false,
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return (index == 0)
            ? Padding(
                padding: const EdgeInsets.only(bottom: kSpacing),
                child: OverviewHeader(
                  axis: headerAxis,
                  onSelected: (task) {},
                ),
              )
            : TaskCard(
                data: data[index - 1],
                onPressedMore: () {},
                onPressedTask: () {},
                onPressedContributors: () {},
                onPressedComments: () {},
              );
      },
      staggeredTileBuilder: (int index) =>
          StaggeredTile.fit((index == 0) ? crossAxisCount : crossAxisCellCount),
    );
  }

  Widget _buildActiveProject({
    required List<ProjectCardData> data,
    int crossAxisCount = 6,
    int crossAxisCellCount = 2,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: ActiveProjectCard(
        onPressedSeeAll: () {},
        child: StaggeredGridView.countBuilder(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          itemCount: data.length,
          addAutomaticKeepAlives: false,
          mainAxisSpacing: kSpacing,
          crossAxisSpacing: kSpacing,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Obx(() => ProjectCard(data: controller.selectedProject.value));
          },
          staggeredTileBuilder: (int index) =>
              StaggeredTile.fit(crossAxisCellCount),
        ),
      ),
    );
  }

  Widget _buildProfile({required Profile data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: ProfileTile(
        data: data,
        onPressedNotification: () {},
      ),
    );
  }

  Widget _buildTeamMember({required List<ImageProvider> data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeamMemberWidget(
            onPressedAdd: () {},
          ),
          const SizedBox(height: kSpacing / 2),
          ListProfilImage(maxImages: 6, images: data),
        ],
      ),
    );
  }

  Widget _buildRecentMessages({required List<ChattingCardData> data}) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpacing),
        child: RecentMessages(onPressedMore: () {}),
      ),
      const SizedBox(height: kSpacing / 2),
      ...data
          .map(
            (e) => ChattingCard(data: e, onPressed: () {}),
          )
          .toList(),
    ]);
  }
}
