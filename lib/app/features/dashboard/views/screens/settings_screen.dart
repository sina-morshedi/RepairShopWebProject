library settings;

import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';
import 'package:repair_shop_web/app/shared_components/SettingsForm.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/settings_controller.dart';


class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) {
          return Column(children: [
            const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
            SettingsForm(),
            const SizedBox(height: kSpacing / 2),

          ]);
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
                    SettingsForm(),
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
                flex: 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing),
                    SettingsForm(),
                    const SizedBox(height: kSpacing * 2),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}


