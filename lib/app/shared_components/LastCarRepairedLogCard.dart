import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarRepairLogResponseDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';

class LastCarRepairedLogCard extends StatefulWidget {
  final String licensePlate;
  final void Function(CarRepairLogResponseDTO log)? onLogFetched;

  const LastCarRepairedLogCard({
    Key? key,
    required this.licensePlate,
    this.onLogFetched,
  }) : super(key: key);

  @override
  State<LastCarRepairedLogCard> createState() => _LastCarRepairedLogCardState();
}

class _LastCarRepairedLogCardState extends State<LastCarRepairedLogCard> {
  CarInfoDTO? carInfo;
  CarRepairLogResponseDTO? latestLog;
  bool isLoading = true;

  final Map<String, String> statusSvgMap = {
    'GÖREV YOK': 'assets/images/vector/stop.svg',
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'İŞ BİTTİ': 'assets/images/vector/finish-flag.svg',
    'FATURA': 'assets/images/vector/bill.svg',
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final car = await fetchCarInfoByPlate(widget.licensePlate);
      final log = await fetchLatestRepairLog(widget.licensePlate);
      print('1');
      if (!mounted) return;
      print('2');
      try {
        if (log != null && widget.onLogFetched != null) {
          widget.onLogFetched!(log);
        }
      } catch (e, stack) {
        print('Error in onLogFetched callback: $e');
        print(stack);
      }
      print('3');
      if (!mounted) return;
      print('car Log');
      print(car.toString());
      print('log');
      print(log.toString());
      setState(() {
        print('test');
        carInfo = car;
        latestLog = log;
        isLoading = false;
        print('Set State');
        print(carInfo.toString());
        print(latestLog.toString());
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (carInfo == null) {
      return const Center(child: Text('Araç bilgisi bulunamadı.'));
    }

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
                  Text('Plaka: ${carInfo!.licensePlate}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Marka: ${carInfo!.brand} ${carInfo!.brandModel}'),
                  Text('Model Yılı: ${carInfo!.modelYear}'),
                  Text('Yakıt Tipi: ${carInfo!.fuelType}'),
                ],
              ),
            ),

            // SVG icon for task status
            if (latestLog?.taskStatus?.taskStatusName != null &&
                statusSvgMap.containsKey(latestLog!.taskStatus!.taskStatusName))
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SvgPicture.asset(
                  statusSvgMap[latestLog!.taskStatus!.taskStatusName]!,
                  width: 48,
                  height: 48,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Dummy service methods — replace these with real API calls

  Future<CarInfoDTO?> fetchCarInfoByPlate(String plate) async {
    // TODO: call your API here
    final response = await backend_services().getCarInfoByLicensePlate(plate);
    if(response.status == 'success')
      return response.data!;
    else
      StringHelper.showErrorDialog(context, response.message!);
    return null;
  }

  Future<CarRepairLogResponseDTO?> fetchLatestRepairLog(String plate) async {
    // TODO: call your API here
    final response = await CarRepairLogApi().getLatestLogByLicensePlate(plate);
    if(response.status == 'success')
      return response.data!;
    else
      StringHelper.showErrorDialog(context, response.message!);
    return null;

  }
}
