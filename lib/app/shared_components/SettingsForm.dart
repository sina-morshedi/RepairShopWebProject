import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:repair_shop_web/app/features/dashboard/models/TaskStatusDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  String selectedSetting = 'Task Status';
  final List<String> settingOptions = ['Task Status', 'Role'];

  bool isAddingNew = false;
  final TextEditingController newEntryController = TextEditingController();

  List<TaskStatusDTO> taskStatusList = [];

  // نگهداری کنترلر و حالت ویرایش برای هر آیتم
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _isEditingMap = {};

  @override
  void initState() {
    super.initState();
    _handleSettingChange(selectedSetting);
  }

  @override
  void dispose() {
    newEntryController.dispose();
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _handleSettingChange(String setting) {
    setState(() {
      selectedSetting = setting;
      isAddingNew = false;
      newEntryController.clear();
    });

    if (setting == 'Task Status') {
      fetchTaskStatuses();
    }
  }

  void fetchTaskStatuses() async {
    final response = await TaskStatusApi().getAllStatuses();
    if (response.status == 'success' && response.data != null) {
      setState(() {
        taskStatusList = response.data!;
        // مقداردهی اولیه کنترلرها و حالت ویرایش هر آیتم
        _controllers.clear();
        _isEditingMap.clear();
        for (var item in taskStatusList) {
          _controllers[item.id ?? ''] = TextEditingController(text: item.taskStatusName);
          _isEditingMap[item.id ?? ''] = false;
        }
      });
    } else {
      print("Failed to fetch task statuses: ${response.message}");
    }
  }

  void sendToBackend(String id, String newValue) async {
    final updated = TaskStatusDTO(
      id: id,
      taskStatusName: newValue.trim(),
    );
    final response = await TaskStatusApi().updateStatus(updated);
    if (response.status == 'success') {
      fetchTaskStatuses();
    } else {
      print("Update failed: ${response.message}");
    }
  }

  // متد حذف اضافه شده
  void deleteTaskStatus(String id) async {
    final response = await TaskStatusApi().deleteStatus(id);
    if (response.status == 'success') {
      setState(() {
        taskStatusList.removeWhere((element) => element.id == id);
        _controllers.remove(id)?.dispose();
        _isEditingMap.remove(id);
      });
    } else {
      print("Delete failed: ${response.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Settings", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedSetting,
            items: settingOptions.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                _handleSettingChange(newValue);
              }
            },
            decoration: const InputDecoration(
              labelText: "Setting",
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Text('$selectedSetting List',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(EvaIcons.plusCircleOutline,
                    color: Colors.blue, size: 28),
                onPressed: () {
                  setState(() {
                    isAddingNew = true;
                  });
                },
              ),
            ],
          ),

          if (isAddingNew)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextFormField(
                controller: newEntryController,
                decoration: InputDecoration(
                  labelText: "Enter new $selectedSetting",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(EvaIcons.checkmarkCircle2Outline),
                    onPressed: () {
                      final value = newEntryController.text.trim();
                      if (value.isNotEmpty) {
                        sendToBackendInsert(value);
                      }
                    },
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          if (selectedSetting == 'Task Status')
            ListView.builder(
              shrinkWrap: true,
              itemCount: taskStatusList.length,
              itemBuilder: (context, index) {
                final item = taskStatusList[index];
                final id = item.id ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[id],
                          readOnly: !_isEditingMap[id]!,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _isEditingMap[id]! ? Colors.white : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isEmpty || value == item.taskStatusName) {
                              setState(() {
                                _isEditingMap[id] = false;
                              });
                              return;
                            }
                            sendToBackend(id, value);
                            setState(() {
                              _isEditingMap[id] = false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      IconButton(
                        icon: Icon(
                          _isEditingMap[id]!
                              ? EvaIcons.checkmarkCircle2Outline
                              : EvaIcons.edit2Outline,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          if (_isEditingMap[id]!) {
                            final newText = _controllers[id]?.text.trim() ?? '';
                            if (newText.isNotEmpty && newText != item.taskStatusName) {
                              sendToBackend(id, newText);
                            }
                            setState(() {
                              _isEditingMap[id] = false;
                            });
                          } else {
                            setState(() {
                              _isEditingMap[id] = true;
                            });
                          }
                        },
                      ),

                      IconButton(
                        icon: const Icon(EvaIcons.trash2Outline, color: Colors.red),
                        onPressed: () {
                          deleteTaskStatus(id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void sendToBackendInsert(String value) async {
    print('test');
    final status = TaskStatusDTO(taskStatusName: value);
    final response = await TaskStatusApi().insertStatus(status);
    if (response.status == 'success') {
      fetchTaskStatuses();
    }
    setState(() {
      isAddingNew = false;
      newEntryController.clear();
    });
  }
}
