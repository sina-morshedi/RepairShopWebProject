import 'dart:developer';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';
import 'package:repair_shop_web/app/shared_components/upgrade_premium_card.dart';
import 'package:repair_shop_web/app/shared_components/project_card.dart';
import 'package:repair_shop_web/app/shared_components/selection_button.dart';
import 'package:repair_shop_web/app/config/routes/app_pages.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.data,
    Key? key,
  }) : super(key: key);

  final ProjectCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kSpacing),
              child: ProjectCard(
                data: data,
              ),
            ),
            const Divider(thickness: 1),
            SelectionButton(
              data: [
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
                  // totalNotif: 20,
                ),
                SelectionButtonData(
                  activeIcon: EvaIcons.person,
                  icon: EvaIcons.personOutline,
                  label: "Profil",
                ),
                SelectionButtonData(
                  activeIcon: EvaIcons.settings,
                  icon: EvaIcons.settingsOutline,
                  label: "ayarlar",
                ),
              ],
              onSelected: (index, value) {
                log("index : $index | label : ${value.label}");

                if (index == 0) {
                  Get.toNamed(Routes.dashboard);
                }if (index == 1) {
                  Get.toNamed(Routes.reports);
                }if (index == 2) {
                  Get.toNamed(Routes.insertCarInfo);
                }if (index == 3) {
                  Get.toNamed(Routes.troubleshooting);
                }
                if (index == 5) {
                  Get.toNamed(Routes.settings);
                }
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(height: kSpacing * 2),
            UpgradePremiumCard(
              backgroundColor: Theme.of(context).canvasColor.withOpacity(.4),
              onPressed: () {},
            ),
            const SizedBox(height: kSpacing),
          ],
        ),
      ),
    );
  }
}
