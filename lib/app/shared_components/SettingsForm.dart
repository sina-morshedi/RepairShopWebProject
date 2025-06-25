import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:repair_shop_web/app/features/dashboard/models/TaskStatusDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/RolesDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  String selectedSetting = 'Görev Durumu';
  final List<String> settingOptions = ['Görev Durumu', 'Roller'];

  bool isAddingNew = false;
  final TextEditingController newEntryController = TextEditingController();

  List<TaskStatusDTO> taskStatusList = [];
  List<RolesDTO> rolesList = [];

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

    if (setting == 'Görev Durumu') {
      fetchTaskStatuses();
    } else if (setting == 'Roller') {
      fetchRoles();
    }
  }

  void fetchRoles() async {
    final response = await RoleApi().getAllRoles();
    if (response.status == 'success' && response.data != null) {
      setState(() {
        rolesList = response.data!;
        for (var item in rolesList) {
          if (!_controllers.containsKey(item.id ?? '')) {
            _controllers[item.id ?? ''] =
                TextEditingController(text: item.roleName);
            _isEditingMap[item.id ?? ''] = false;
          }
        }
      });
    } else {
      StringHelper.showErrorDialog(context, "Failed to fetch roles: ${response.message}");
    }
  }

  void fetchTaskStatuses() async {
    final response = await TaskStatusApi().getAllStatuses();
    if (response.status == 'success' && response.data != null) {
      setState(() {
        taskStatusList = response.data!;
        for (var item in taskStatusList) {
          if (!_controllers.containsKey(item.id ?? '')) {
            _controllers[item.id ?? ''] =
                TextEditingController(text: item.taskStatusName);
            _isEditingMap[item.id ?? ''] = false;
          }
        }
      });
    } else {
      StringHelper.showErrorDialog(context, "Failed to fetch task statuses: ${response.message}");
    }
  }

  void sendToBackend(String id, String newValue) async {
    final updated = TaskStatusDTO(id: id, taskStatusName: newValue.trim());
    final response = await TaskStatusApi().updateStatus(updated);
    if (response.status == 'success') {
      fetchTaskStatuses();
    } else {
      StringHelper.showErrorDialog(context, "${response.message}");
    }
  }

  void updateRole(String id, String newValue) async {
    final updated = RolesDTO(id: id, roleName: newValue.trim());
    final response = await RoleApi().updateRole(updated);
    if (response.status == 'success') {
      fetchRoles();
    } else {
      StringHelper.showErrorDialog(context, "Update failed: ${response.message}");
    }
  }

  void deleteTaskStatus(String id) async {
    final response = await TaskStatusApi().deleteStatus(id);
    if (response.status == 'success') {
      setState(() {
        taskStatusList.removeWhere((element) => element.id == id);
        _controllers.remove(id)?.dispose();
        _isEditingMap.remove(id);
      });
    } else {
      StringHelper.showErrorDialog(context, "Delete failed: ${response.message}");
    }
  }

  void deleteRole(String id) async {
    final response = await RoleApi().deleteRole(id);
    if (response.status == 'success') {
      setState(() {
        rolesList.removeWhere((element) => element.id == id);
        _controllers.remove(id)?.dispose();
        _isEditingMap.remove(id);
      });
    } else {
      StringHelper.showErrorDialog(context, "Delete failed: ${response.message}");
    }
  }

  void sendToBackendInsert(String value) async {
    if (selectedSetting == 'Görev Durumu') {
      final status = TaskStatusDTO(taskStatusName: value);
      final response = await TaskStatusApi().insertStatus(status);
      if (response.status == 'success') {
        fetchTaskStatuses();
      } else {
        StringHelper.showErrorDialog(context, "Hata: ${response.message}");
      }
    } else if (selectedSetting == 'Roller') {
      final role = RolesDTO(roleName: value);
      final response = await RoleApi().insertRole(role);
      if (response.status == 'success') {
        fetchRoles();
      } else {
        StringHelper.showErrorDialog(context, "Hata: ${response.message}");
      }
    }

    setState(() {
      isAddingNew = false;
      newEntryController.clear();
    });
  }

  Widget _buildEditableItem({
    required String id,
    required String initialText,
    required Function(String) onSave,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controllers[id],
              readOnly: !_isEditingMap[id]!,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: _isEditingMap[id]! ? Colors.white : Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (value) {
                if (value.trim().isEmpty || value == initialText) {
                  setState(() {
                    _isEditingMap[id] = false;
                  });
                  return;
                }
                onSave(value);
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
                if (newText.isNotEmpty && newText != initialText) {
                  onSave(newText);
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
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: taskStatusList.length,
      itemBuilder: (context, index) {
        final item = taskStatusList[index];
        final id = item.id ?? '';
        return _buildEditableItem(
          id: id,
          initialText: item.taskStatusName,
          onSave: (value) => sendToBackend(id, value),
          onDelete: () => deleteTaskStatus(id),
        );
      },
    );
  }

  Widget _buildRoleList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: rolesList.length,
      itemBuilder: (context, index) {
        final item = rolesList[index];
        final id = item.id ?? '';
        return _buildEditableItem(
          id: id,
          initialText: item.roleName,
          onSave: (value) => updateRole(id, value),
          onDelete: () => deleteRole(id),
        );
      },
    );
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
                icon: const Icon(EvaIcons.plusCircleOutline, color: Colors.blue, size: 28),
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
          if (selectedSetting == 'Görev Durumu') _buildTaskStatusList(),
          if (selectedSetting == 'Roller') _buildRoleList(),
        ],
      ),
    );
  }
}
