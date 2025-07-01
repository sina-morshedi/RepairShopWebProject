import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';

class CarRepairedLogCard extends StatelessWidget {
  final CarRepairLogResponseDTO log;

  const CarRepairedLogCard({Key? key, required this.log}) : super(key: key);

  final Map<String, String> statusSvgMap = const {
    'GÖREV YOK': 'assets/images/vector/stop.svg',
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'SON': 'assets/images/vector/finish-flag.svg',
  };

  @override
  Widget build(BuildContext context) {
    final carInfo = log.carInfo;

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    'Plaka: ${carInfo?.licensePlate ?? "-"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText('Marka: ${carInfo?.brand ?? ""} ${carInfo?.brandModel ?? ""}'),
                  SelectableText('Model Yılı: ${carInfo?.modelYear ?? ""}'),
                  SelectableText('Yakıt Tipi: ${carInfo?.fuelType ?? ""}'),
                ],
              ),
            ),

            // Task status SVG
            if (log.taskStatus?.taskStatusName != null &&
                statusSvgMap.containsKey(log.taskStatus!.taskStatusName))
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SvgPicture.asset(
                  statusSvgMap[log.taskStatus!.taskStatusName]!,
                  width: 48,
                  height: 48,
                ),
              ),
          ],
        ),
      ),
    );

  }
}
