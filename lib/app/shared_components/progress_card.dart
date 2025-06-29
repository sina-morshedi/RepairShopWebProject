import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';

class ProgressCardData {
  final int totalUndone;
  final int totalTaskInProress;

  const ProgressCardData({
    required this.totalUndone,
    required this.totalTaskInProress,
  });
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.data,
    required this.onPressedCheck,
    Key? key,
  }) : super(key: key);

  final ProgressCardData data;
  final Function() onPressedCheck;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kBorderRadius),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: const Offset(0, 0),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: SvgPicture.asset(
                    ImageVectorPath.enteredGarage,
                    // fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: kSpacing,
              top: kSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Araç giriş menüsü",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: kSpacing),
                ElevatedButton(
                  onPressed: () async {
                    await CarEntryDialog.show(context);
                  },
                  child: const Text("araba girişi"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
