library insert_car_info;

import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';
import 'package:repair_shop_web/app/shared_components/InsertCarInfoForm.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/insertcarinfo_controller.dart';


class InsertCarInfoScreen extends GetView<InsertcarinfoController> {
  const InsertCarInfoScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) {
          return Column(children: [
            const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
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
                flex: (constraints.maxWidth < 950) ? 6 : 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
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
                flex: 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing),
                    InsertCarInfoForm(),

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
