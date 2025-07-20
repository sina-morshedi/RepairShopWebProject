import '../features/dashboard/models/CarRepairLogResponseDTO.dart';
import 'CarRepairLogListView.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';

import '../utils/helpers/app_helpers.dart';
import '../features/dashboard/models/UserProfileDTO.dart';
import '../features/dashboard/models/CarRepairLogRequestDTO.dart';
import '../features/dashboard/models/TaskStatusUserRequestDTO.dart';

class RepairmanLogTask extends StatefulWidget {
  final UserProfileDTO user;
  const RepairmanLogTask({super.key, required this.user});

  @override
  State<RepairmanLogTask> createState() => RepairmanLogTaskState();
}

class RepairmanLogTaskState extends State<RepairmanLogTask>{
  late UserProfileDTO user;
  List<CarRepairLogResponseDTO> logs = [];

  String first_name = '';
  String last_name = '';
  String role_name = '';

  void reloadUserData() {
    _loadUser();
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _loadUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadUser() async {

    if (user != null && user!.role != null && user!.permission != null) {
      setState(() {
        first_name = user!.firstName;
        last_name = user!.lastName;
        role_name = user!.role!.roleName;
      });
    } else {
      debugPrint("user or one of its nested fields is null");
    }
    final request = TaskStatusUserRequestDTO(
      assignedUserId: user!.userId,
      taskStatusNames: ["USTA"],
    );
    final response = await CarRepairLogApi().getLatestLogsByTaskStatusesAndUserId(request);
    if(response.status == 'success'){
      setState(() {
        logs = response.data!;
      });
    }
    else
      StringHelper.showErrorDialog(context, response.message!);
  }


  void _handleLogButtonPressed(CarRepairLogResponseDTO log) async{
    
    final responseTask = await TaskStatusApi().getTaskStatusByName("BAŞLANGIÇ");
    if(responseTask.status == 'success'){
      final customerId = log?.customer?.id ?? "";
      final request = CarRepairLogRequestDTO(
          carId: log.carInfo.id,
          creatorUserId: user!.userId,
          taskStatusId: responseTask.data!.id!,
          problemReportId: log.problemReport!.id,
          assignedUserId: log.assignedUser!.userId,
          description: log.description,
          dateTime: DateTime.now(),
          customerId: customerId,
      );

      final response = await CarRepairLogApi().createLog(request);
      if(response.status == 'success')
        StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
      else
        StringHelper.showErrorDialog(context, response.message!);
    }
    else{
      StringHelper.showErrorDialog(context, responseTask.message!);
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '$first_name $last_name',
                        overflow: TextOverflow.ellipsis,
                      ),

                      Spacer(),

                      Text(
                        role_name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),
              Text(
                "Çalışanın Görevleri",
              ),
              SizedBox(height: 12),
              Expanded(
                child: CarRepairLogListView(
                  logs: logs,
                  buttonBuilder: (log) {
                    return {
                      'text': 'İşe başlıyorum.',
                      'onPressed': () {
                        _handleLogButtonPressed(log);
                      },
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}


