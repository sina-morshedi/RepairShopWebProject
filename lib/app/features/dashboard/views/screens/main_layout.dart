import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:repair_shop_web/app/features/dashboard/views/components/sidebar.dart';
import 'package:repair_shop_web/app/features/dashboard/views/components/header.dart';
import 'package:repair_shop_web/app/features/dashboard/views/components/profile_tile.dart';
import 'package:repair_shop_web/app/features/dashboard/views/components/team_member.dart';
import 'package:repair_shop_web/app/shared_components/list_profil_image.dart';
import 'package:repair_shop_web/app/features/dashboard/views/components/recent_messages.dart';
import 'package:repair_shop_web/app/shared_components/responsive_builder.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'main-layout');

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveBuilder.isDesktop(context);
    final dashboardController = Get.find<DashboardController>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop
          ? null
          : Drawer(
        child: Padding(
          padding: const EdgeInsets.only(top: kSpacing),
          child: Sidebar(data: dashboardController.getSelectedProject()),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Flexible(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(kBorderRadius),
                  bottomRight: Radius.circular(kBorderRadius),
                ),
                child: Sidebar(data: dashboardController.getSelectedProject()),
              ),
            ),
          Flexible(
            flex: 9,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacing),
                  child: Row(
                    children: [
                      if (!ResponsiveBuilder.isDesktop(context))
                        Padding(
                          padding: const EdgeInsets.only(right: kSpacing),
                          child: IconButton(
                            icon: const Icon(Icons.menu),
                            tooltip: "Menü",
                            onPressed: openDrawer,
                          ),
                        ),
                      const Expanded(child: Header()),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(child: widget.child),
                ),
              ],
            ),
          ),
          if (isDesktop)
            Flexible(
              flex: 4,
              child: Column(
                children: [
                  const SizedBox(height: kSpacing / 2),
                  Obx(() {
                    final profile = dashboardController.getProfil();

                    if (profile == null) {
                      return const SizedBox();
                    }

                    return ProfileTile(
                      data: profile,
                      onPressedNotification: () {},
                    );
                  }),
                  const Divider(thickness: 1),
                  const SizedBox(height: kSpacing),
                  TeamMemberWidget(onPressedAdd: () {}),
                  const SizedBox(height: kSpacing / 2),
                  ListProfilImage(
                    maxImages: 6,
                    images: dashboardController.getMember(),
                  ),
                  const SizedBox(height: kSpacing),
                  const Divider(thickness: 1),
                  const SizedBox(height: kSpacing),
                  RecentMessages(onPressedMore: () {}),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

