import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarRepairLogResponseDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';

class CarEntryDialog extends StatefulWidget {
  const CarEntryDialog({super.key});

  @override
  State<CarEntryDialog> createState() => _CarEntryDialogState();

  static Future<CarInfoDTO?> show(BuildContext context) async {
    return showDialog<CarInfoDTO>(
      context: context,
      builder: (context) => const CarEntryDialog(),
    );
  }
}

class _CarEntryDialogState extends State<CarEntryDialog> {
  final TextEditingController _searchController = TextEditingController();
  CarInfoDTO? selectedCar;
  CarRepairLogResponseDTO? latestLog;
  TaskStatusDTO? taskStatusLog;
  bool isLoading = false;
  bool foundLog = false;

  final Map<String, String> statusSvgMap = {
    'GÖREV YOK': 'assets/images/vector/stop.svg',
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'SON': 'assets/images/vector/finish-flag.svg',
  };

  Future<void> _CarEntry() async{
    final userController = Get.find<UserController>();
    final userId = userController.currentUser?.userId ?? "";

    print('_CarEntry');
    if(selectedCar != null) {
      final logRequest = CarRepairLogRequestDTO(
        carId: selectedCar!.id,
        creatorUserId: userId,
        description: '',
        taskStatusId: taskStatusLog!.id!,
        dateTime: DateTime.now(),
        problemReportId: null,
      );

      final response = await CarRepairLogApi().createLog(logRequest);

      if(response.status == 'success' && response.data != null)
        StringHelper.showInfoDialog(context, 'Araba girişi kaydedildi');
      else
        StringHelper.showErrorDialog(context, 'Creat Log: ${response.message!}');


    }
  }
  
  Future<void> _search() async {
    final plate = _searchController.text.trim().toUpperCase();
    if (plate.isEmpty) return;

    setState(() {
      isLoading = true;
      selectedCar = null;
      latestLog = null;
    });

    final carResponse = await backend_services().getCarInfoByLicensePlate(plate);


    setState(() => isLoading = false);

    if (carResponse.status == 'success')
      selectedCar = carResponse.data;
    else {
      StringHelper.showErrorDialog(
          context, 'Car Response: ${carResponse.message!}');
      return;
    }

    if (selectedCar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç bulunamadı')),
      );
      return;
    }

    final logResponse = await CarRepairLogApi().getLatestLogByLicensePlate(plate);
    if (logResponse.status == 'success') {
      foundLog = true;
      setState(() {
        latestLog = logResponse.data;
      });

    } else {
      foundLog = false;
      StringHelper.showErrorDialog(
          context, 'Log Response: ${logResponse.message!}');
      return;
    }

    final taskStatus  = await TaskStatusApi().getTaskStatusByName('GİRMEK');
    if(taskStatus.status == 'success') {

      setState(() {
        taskStatusLog = taskStatus.data;
      });

    } else
      StringHelper.showErrorDialog(context, 'Task Status Respone: ${taskStatus.message!}');


  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Araç Ara'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Plaka',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator()
            else if (selectedCar != null)
              Card(
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
                            Text('Plaka: ${selectedCar!.licensePlate}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Marka: ${selectedCar!.brand} ${selectedCar!.brandModel}'),
                            Text('Model Yılı: ${selectedCar!.modelYear}'),
                            Text('Yakıt Tipi: ${selectedCar!.fuelType}'),
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
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Cancel
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: (){
            print('onPressed');
            if(!foundLog)
              _CarEntry();
            else if(latestLog!.taskStatus.taskStatusName  == 'GÖREV YOK')
              _CarEntry();
            else
              StringHelper.showErrorDialog(context, 'Araba şu anda tamir aşamasında.');
          },
          child: const Text('Araba girişi'),
        ),
      ],
    );
  }
}
