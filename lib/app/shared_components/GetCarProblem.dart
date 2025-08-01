import 'dart:math';

import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/shared_components/LastCarRepairedLogCard.dart';

class GetCarProblem extends StatefulWidget {
  final String? plate;
  final VoidCallback? onProblemSaved;  // این خط جدید

  const GetCarProblem({super.key, this.plate, this.onProblemSaved});

  @override
  _GetCarProblemState createState() => _GetCarProblemState();
}

class _GetCarProblemState extends State<GetCarProblem>{
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  CarRepairLogResponseDTO? carLog;

  CarInfoDTO? carInfo;
  bool isLoading = false;
  bool needUpdate = false;

  bool isPlateReadOnly = false;

  @override
  void initState() {
    super.initState();

    if (widget.plate != null && widget.plate!.isNotEmpty) {
      _licensePlateController.text = widget.plate!.toUpperCase();
      isPlateReadOnly = true;
      _searchCar();
    }
  }

  void _searchCar() async {
    needUpdate = false;
    final plate = _licensePlateController.text.trim().toUpperCase();
    if (plate.isEmpty) return;

    setState(() => isLoading = true);

    final response = await CarInfoApi().getCarInfoByLicensePlate(plate);

    if (response.status == 'success' && response.data != null) {
      setState(() {
        carInfo = response.data;
        isLoading = false;
      });
      final responseLog = await CarRepairLogApi().getLatestLogByLicensePlate(plate);
      if(responseLog.status == 'success'){
        carLog = responseLog.data;
        if(carLog!.taskStatus.taskStatusName == 'SORUN GİDERME'){
          setState(() {
            needUpdate= true;
            _problemController.text = carLog!.problemReport!.problemSummary!;
          });

        }
      } else
        StringHelper.showErrorDialog(context, responseLog.message!);

    } else {
      setState(() {
        carInfo = null;
        isLoading = false;
      });
      StringHelper.showErrorDialog(context, "Bu plakaya ait araç bulunamadı");
    }
  }

  void _saveProblemReport() async {
    if (carInfo == null) return;
    final problemText = _problemController.text.trim();
    if (problemText.isEmpty) {
      StringHelper.showErrorDialog(context, "Lütfen problemi giriniz");
      return;
    }

    final userController = Get.find<UserController>();
    final userId = userController.currentUser?.userId ?? "";


    // Create problem report DTO
    final reportDTO = CarProblemReportRequestDTO(
      carId: carInfo!.id!,
      creatorUserId: userId,
      problemSummary: problemText,
      dateTime: DateTime.now(),

    );

    // Save problem report
    final saveResponse = await CarProblemReportApi().createReport(reportDTO);

    if (saveResponse.status == 'success' && saveResponse.data != null) {
      _problemController.clear();

      // Now create a CarRepairLog based on saved problem report
      final createdProblemReport = saveResponse.data!;


      final taskStatus  = await TaskStatusApi().getTaskStatusByName('SORUN GİDERME');
      if(taskStatus.status != 'success') {
        StringHelper.showErrorDialog(
            context, 'Task Status Respone: ${taskStatus.message!}');
        return;
      }
      if (taskStatus.status == 'success' && taskStatus.data != null) {

        if(needUpdate){
          final reportDTO = CarProblemReportRequestDTO(
            id: carLog!.problemReport!.id,
            carId: carLog!.carInfo.id,
            creatorUserId: userId,
            problemSummary: problemText,
            dateTime: DateTime.now(),
          );
          final updateResponse = await CarProblemReportApi().updateReport(reportDTO);
          if(updateResponse.status == 'success') {
            StringHelper.showInfoDialog(context, updateResponse.message!);
            widget.onProblemSaved?.call();
          } else
            StringHelper.showErrorDialog(context, updateResponse.message!);

          return;
        }

        final customerId = carLog?.customer?.id ?? "";
        final logRequest = CarRepairLogRequestDTO(
          carId: createdProblemReport.carId,
          creatorUserId: userId,
          description: '',
          taskStatusId: taskStatus.data!.id!,
          dateTime: DateTime.now(),
          problemReportId: createdProblemReport.id,
          customerId: customerId,
        );

        final logResponse = await CarRepairLogApi().createLog(logRequest);

        if (logResponse.status == 'success') {
          widget.onProblemSaved?.call();
          StringHelper.showInfoDialog(
              context,"başarıyla oluşturuldu.");
        } else {
          StringHelper.showErrorDialog(
              context,logResponse.message!);
        }
      } else {
        StringHelper.showErrorDialog(
            context,taskStatus.message!);
      }


    } else {
      // Show error if saving problem report failed
      StringHelper.showErrorDialog(
          context,
          saveResponse.message!
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16), // پدینگ بیرونی
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اگر پلاک از بیرون پاس داده شده باشد، تکس‌فیلد پلاک را نمایش نده
          if (widget.plate == null || widget.plate!.isEmpty)
            TextField(
              controller: _licensePlateController,
              onSubmitted: (_) => _searchCar(),
              decoration: InputDecoration(
                labelText: "Plaka Numarası",
                border: const OutlineInputBorder(), // ← این خط باعث ظاهر بوردر کامل میشه
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchCar,
                ),
              ),
            ),


          SizedBox(height: 10),
          if (isLoading) Center(child: CircularProgressIndicator()),
          if (carInfo != null) ...[
            SizedBox(height: 16),
            LastCarRepairedLogCard(
              licensePlate: _licensePlateController.text.trim().toUpperCase(),
              onLogFetched: (log) {
                setState(() {
                  carLog = log;
                  _problemController.text = log.problemReport!.problemSummary!;
                });
              },
            ),
            SizedBox(height: 16),

            if (carLog != null &&
                (carLog!.taskStatus?.taskStatusName == 'GİRMEK' ||
                    carLog!.taskStatus.taskStatusName == 'SORUN GİDERME')) ...[
              TextField(
                controller: _problemController,
                onSubmitted: (_) => _saveProblemReport(),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Problem Açıklaması",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProblemReport,
                  child: Text("Problemi Kaydet"),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }


}

