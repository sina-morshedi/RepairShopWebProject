library project_manage;

import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';
import 'package:repair_shop_web/app/shared_components/InvoiceForm.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/invoice_controller.dart';


class IncoiceScreen extends GetView<InvoiceController> {
  const IncoiceScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: ResponsiveBuilder(
            mobileBuilder: (context, constraints) {
              return Column(children: [
                const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
                const SizedBox(height: kSpacing),
                const Divider(),
                InvoiceForm(),
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
                        InvoiceForm(),
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
                        InvoiceForm(),
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


