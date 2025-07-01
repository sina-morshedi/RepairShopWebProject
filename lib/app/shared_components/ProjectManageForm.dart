import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';

class ProjectmanageForm extends StatefulWidget {
  @override
  _ProjectmanageFormState createState() => _ProjectmanageFormState();
}

class _ProjectmanageFormState extends State<ProjectmanageForm>{
  List<CarRepairLogResponseDTO>? carRepairLogs;
  List<UserProfile>? users;
  List<String?> selectedUserIds = [];
  List<bool> approvedFlags = [];

  final Map<String, String> statusSvgMap = const {
    'GÖREV YOK': 'assets/images/vector/stop.svg',
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'SON': 'assets/images/vector/finish-flag.svg',
  };

  @override
  void initState() {
    super.initState();
  }

  void fetchLatestLogs() async {
    final carLogs = await CarRepairLogApi().getLatestLogByTaskStatusName('SORUN GİDERME');
    final usersLogs = await backend_services().fetchAllProfile();

    if (carLogs.status == 'success') {
      setState(() {
        carRepairLogs = carLogs.data;
        selectedUserIds = List.filled(carRepairLogs!.length, null);
        approvedFlags = List.filled(carRepairLogs!.length, false);
      });
    } else {
      StringHelper.showErrorDialog(context, carLogs.message!);
    }

    if (usersLogs.status == 'success') {
      setState(() {
        users = usersLogs.data!;
      });
    } else {
      StringHelper.showErrorDialog(context, usersLogs.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carRepairLogs == null || users == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(carRepairLogs!.length, (index) {
          final log = carRepairLogs![index];
          final carInfo = log.carInfo;
          final taskStatusName = log.taskStatus?.taskStatusName ?? '';
          final svgPath = statusSvgMap[taskStatusName];
          final selectedUserId = selectedUserIds[index];
          final approved = approvedFlags[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // مشخصات خودرو
                  Expanded(
                    flex: 3,
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

                  // Dropdown با border
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedUserId,
                          hint: const Text("Kullanıcı seçin"),
                          items: users!.map((user) {
                            return DropdownMenuItem<String>(
                              value: user.userId,
                              child: Text(user.username ?? "No Username"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedUserIds[index] = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // آیکون SVG بین دراپ‌داون و تیک
                  if (svgPath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SvgPicture.asset(
                        svgPath,
                        width: 50,
                        height: 50,
                        placeholderBuilder: (context) => const CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),

                  const SizedBox(width: 12),

                  // آیکون تیک یا لاک
                  Column(
                    children: [
                      if (!approved)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              approvedFlags[index] = true;
                            });
                            print('✅ Log approved: ${log.id}, selected user: $selectedUserId');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.shade100,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 32,
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: const [
                              Icon(Icons.lock, size: 20, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Approved', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
