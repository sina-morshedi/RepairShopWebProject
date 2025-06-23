import 'dart:developer';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';
import 'package:repair_shop_web/app/shared_components/upgrade_premium_card.dart';
import 'package:repair_shop_web/app/shared_components/project_card.dart';
import 'package:repair_shop_web/app/shared_components/selection_button.dart';
import 'package:repair_shop_web/app/config/routes/app_pages.dart';
import 'package:repair_shop_web/app/config/themes/app_theme.dart';
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
                  label: "Reports",
                ),
                SelectionButtonData(
                  activeIcon: EvaIcons.calendar,
                  icon: EvaIcons.calendarOutline,
                  label: "Calendar",
                ),
                SelectionButtonData(
                  activeIcon: EvaIcons.email,
                  icon: EvaIcons.emailOutline,
                  label: "Email",
                  totalNotif: 20,
                ),
                SelectionButtonData(
                  activeIcon: EvaIcons.person,
                  icon: EvaIcons.personOutline,
                  label: "Profil",
                ),
                SelectionButtonData(
                  activeIcon: EvaIcons.settings,
                  icon: EvaIcons.settingsOutline,
                  label: "Setting",
                ),
              ],
              onSelected: (index, value) {
                log("index : $index | label : ${value.label}");
                if (value.label == "Calendar") {
                  Get.toNamed(Routes.insertCarInfo);
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
