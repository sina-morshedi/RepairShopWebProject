library insert_car_info;

import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';
import 'package:repair_shop_web/app/shared_components/InsertCarInfoForm.dart';


class InsertCarInfoScreen extends GetView<InsertcarinfoController> {
  const InsertCarInfoScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: (ResponsiveBuilder.isDesktop(context))
          ? null
          : Drawer(
              child: Padding(
                padding: const EdgeInsets.only(top: kSpacing),
                child: Sidebar(data: controller.getSelectedProject()),
              ),
            ),
      body: SingleChildScrollView(
          child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) {
          return Column(children: [
            _buildProfile(data: controller.getProfil()),
            const SizedBox(height: kSpacing),
            const Divider(),
            const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
            _buildHeader(onPressedMenu: () => controller.openDrawer()),
            const SizedBox(height: kSpacing),
            const Divider(),
            InsertCarInfoForm(),
            const SizedBox(height: kSpacing / 2),



          ]);
        },
        tabletBuilder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing * (kIsWeb ? 0.5 : 1.5)),
                    _buildProfile(data: controller.getProfil()),
                    const Divider(thickness: 1),

                  ],
                ),
              ),
              Flexible(
                flex: (constraints.maxWidth < 950) ? 6 : 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
                    _buildHeader(onPressedMenu: () => controller.openDrawer()),
                    const SizedBox(height: kSpacing * 2),
                    InsertCarInfoForm(),
                    const SizedBox(height: kSpacing * 2),

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
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(kBorderRadius),
                      bottomRight: Radius.circular(kBorderRadius),
                    ),
                    child: Sidebar(data: controller.getSelectedProject())),
              ),
              Flexible(
                flex: 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing),
                    _buildHeader(),
                    InsertCarInfoForm(),

                    const SizedBox(height: kSpacing * 2),
                  ],
                ),
              ),
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing / 2),
                    _buildProfile(data: controller.getProfil()),
                    const Divider(thickness: 1),
                  ],
                ),
              )
            ],
          );
        },
      )),
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


  Widget _buildProfile({required Profile data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: ProfilTile(
        data: data,
        onPressedNotification: () {},
      ),
    );
  }

  Widget _buildCarForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("اطلاعات خودرو", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: kSpacing),

            TextFormField(decoration: const InputDecoration(labelText: "شماره شاسی")),
            const SizedBox(height: kSpacing / 2),

            TextFormField(decoration: const InputDecoration(labelText: "شماره موتور")),
            const SizedBox(height: kSpacing / 2),

            TextFormField(decoration: const InputDecoration(labelText: "شماره پلاک")),
            const SizedBox(height: kSpacing / 2),

            TextFormField(decoration: const InputDecoration(labelText: "برند خودرو")),
            const SizedBox(height: kSpacing / 2),

            TextFormField(decoration: const InputDecoration(labelText: "مدل خودرو")),
            const SizedBox(height: kSpacing / 2),

            TextFormField(
              decoration: const InputDecoration(labelText: "سال ساخت"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: kSpacing / 2),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "نوع سوخت"),
              items: const [
                DropdownMenuItem(value: "بنزین", child: Text("بنزین")),
                DropdownMenuItem(value: "دیزل", child: Text("دیزل")),
                DropdownMenuItem(value: "گاز", child: Text("گاز")),
                DropdownMenuItem(value: "برقی", child: Text("برقی")),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: kSpacing * 2),
          ],
        ),
      ),
    );
  }

}
