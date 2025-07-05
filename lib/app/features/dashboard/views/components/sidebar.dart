import 'dart:developer';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';
import 'package:repair_shop_web/app/shared_components/upgrade_premium_card.dart';
import 'package:repair_shop_web/app/shared_components/project_card.dart';
import 'package:repair_shop_web/app/shared_components/selection_button.dart';
import 'package:repair_shop_web/app/config/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';

import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.data,
    Key? key,
  }) : super(key: key);

  final ProjectCardData data;

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final permissionName =
        userController.currentUser?.permission.permissionName ?? "";

    // Build the selection buttons list dynamically based on permission
    final List<SelectionButtonData> selectionData = [
      SelectionButtonData(
        activeIcon: EvaIcons.grid,
        icon: EvaIcons.gridOutline,
        label: "Dashboard",
      ),
      SelectionButtonData(
        activeIcon: EvaIcons.archive,
        icon: EvaIcons.archiveOutline,
        label: "Raporlar",
      ),
      SelectionButtonData(
        activeIcon: EvaIcons.car,
        icon: EvaIcons.carOutline,
        label: "Araç ayrıntılarını ekle",
      ),
      SelectionButtonData(
        activeIcon: FontAwesomeIcons.stethoscope,
        icon: FontAwesomeIcons.stethoscope,
        label: "Araba arıza raporu alın",
      ),
    ];
    if (permissionName == "Yönetici") {
      selectionData.add(SelectionButtonData(
        activeIcon: EvaIcons.person,
        icon: EvaIcons.briefcaseOutline,
        label: "Proje yönetimi",
      ));
    }
    // Add "ayarlar" button only if permission is "Yönetici"
    if (permissionName == "Yönetici") {
      selectionData.add(
        SelectionButtonData(
          activeIcon: EvaIcons.settings,
          icon: EvaIcons.settingsOutline,
          label: "ayarlar",
        ),
      );
    }

    return Container(
      color: Theme.of(context).cardColor,
      height: MediaQuery.of(context).size.height, // <-- این خط مهمه
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kSpacing),
              child: ProjectCard(data: data),
            ),
            const Divider(thickness: 1),
            SelectionButton(
              data: selectionData,
              onSelected: (index, value) {
                log("index : $index | label : ${value.label}");
                switch (value.label) {
                  case "Dashboard":
                    Get.toNamed(Routes.dashboard);
                    break;
                  case "Raporlar":
                    Get.toNamed(Routes.reports);
                    break;
                  case "Araç ayrıntılarını ekle":
                    Get.toNamed(Routes.insertCarInfo);
                    break;
                  case "Araba arıza raporu alın":
                    Get.toNamed(Routes.troubleshooting);
                    break;
                  case "Proje yönetimi":
                    Get.toNamed(Routes.projectManage);
                    break;
                  case "ayarlar":
                    Get.toNamed(Routes.settings);
                    break;
                }
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(height: kSpacing),
          ],
        ),
      ),
    );

  }
}
