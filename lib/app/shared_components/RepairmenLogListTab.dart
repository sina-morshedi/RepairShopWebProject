import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import '../features/dashboard/backend_services/backend_services.dart';
import '../features/dashboard/models/UserProfileDTO.dart';
import 'RepairmanLogTask.dart';
import 'RepairmanWorkespace.dart';

class RepairmenLogListTab extends StatefulWidget {
  const RepairmenLogListTab({super.key});

  @override
  State<RepairmenLogListTab> createState() => _RepairmenLogListTabState();
}

class _RepairmenLogListTabState extends State<RepairmenLogListTab> {
  List<UserProfileDTO> repairmen = [];
  UserProfileDTO? selectedRepairman;
  String? selectedTaskType;

  final List<String> taskOptions = [
    'Yapılacak işler', // کارهایی که باید انجام شود
    'Devam eden işler', // کارهای در حال انجام
  ];

  @override
  void initState() {
    super.initState();
    _loadRepairmen();
  }

  Future<void> _loadRepairmen() async {
    final response = await UserApi().getAllUsers();
    List<UserProfileDTO>? users;
    if (response.status == 'success') {
      users = response.data;
    } else {
      StringHelper.showErrorDialog(context, response.message!);
      return;
    }

    // فقط اونایی که نقش "Tamirci" دارن رو فیلتر کن
    List<UserProfileDTO> filtered = users
        ?.where((user) => user.permission?.permissionName == 'Tamirci')
        .toList() ??
        [];

    setState(() {
      repairmen = filtered;
      selectedRepairman = filtered.isNotEmpty ? filtered.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: repairmen.isEmpty
          ? const CircularProgressIndicator()
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "Tamirci Seçin:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserProfileDTO>(
            value: repairmen.contains(selectedRepairman)
                ? selectedRepairman
                : null,
            decoration: InputDecoration(
              labelText: 'Tamircilar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: repairmen
                .map((user) => DropdownMenuItem<UserProfileDTO>(
              value: user,
              child: Text('${user.firstName} ${user.lastName}'),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedRepairman = value;
                selectedTaskType = null; // ریست نوع کار وقتی تعمیرکار عوض شد
              });
            },
          ),

          if (selectedRepairman != null) ...[
            const SizedBox(height: 24),
            const Text(
              "Görev Türünü Seçin:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedTaskType,
              decoration: InputDecoration(
                labelText: 'Görevler',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: taskOptions
                  .map((task) => DropdownMenuItem<String>(
                value: task,
                child: Text(task),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedTaskType = value;
                });
              },
            ),
          ],

          // اینجا ویجت RepairmanLogTask را نمایش بده وقتی هر دو مقدار انتخاب شده‌اند
          if (selectedRepairman != null && selectedTaskType == 'Yapılacak işler') ...[
            const SizedBox(height: 24),
            Expanded(
              child: RepairmanLogTask(user: selectedRepairman!),
            ),
          ],
          if (selectedRepairman != null && selectedTaskType == 'Devam eden işler') ...[
            const SizedBox(height: 24),
            Expanded(
              child: RepairmanWorkespace(user: selectedRepairman!),
            ),
          ],

        ],
      ),
    );
  }

}
