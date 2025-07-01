library troubleshooting;

import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';
import 'package:repair_shop_web/app/shared_components/TroubleshootingForm.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/troubleshooting_controller.dart';


class TroubleshootingScreen extends GetView<TroubleshootingController> {
  const TroubleshootingScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: ResponsiveBuilder(
            mobileBuilder: (context, constraints) {
              return Column(children: [
                const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
                TroubleshootingForm(),
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
                        TroubleshootingForm(),
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
                        TroubleshootingForm(),
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


