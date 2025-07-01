import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/shared_components/CarRepairLogListView.dart';
import 'package:flutter/material.dart';

class FilterReportsTab extends StatefulWidget {
  const FilterReportsTab({super.key});

  @override
  State<FilterReportsTab> createState() => _FilterReportsTabState();
}

class _FilterReportsTabState extends State<FilterReportsTab> with RouteAware {
  String? selectedFilter; // "Plaka" یا "Görev Durumu"
  final TextEditingController _plateController = TextEditingController();
  String? selectedStatus;
  List<CarRepairLogResponseDTO> _logs = [];

  final List<String> filterOptions = ['Plaka', 'Görev Durumu'];

  final Map<String, String> statusSvgMap = {
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'SON': 'assets/images/vector/finish-flag.svg',
  };


  List<TaskStatusDTO> taskStatuses = [];
  List<CarRepairLogResponseDTO> filteredReports = [];

  @override
  void initState() {
    super.initState();
    fetchTaskStatuses();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }


  Future<void> fetchTaskStatuses() async {
    final response = await TaskStatusApi().getAllStatuses();
    if (response.status == 'success' && response.data != null) {
      setState(() {
        taskStatuses = List<TaskStatusDTO>.from(response.data!);
      });
    } else {
      StringHelper.showErrorDialog(
          context, "Görev durumları alınamadı: ${response.message}");
    }
  }

  void _filter_handler() async {
    if (selectedFilter == 'Plaka') {
      if (_plateController.text.trim().isEmpty) {
        StringHelper.showErrorDialog(context, 'Lütfen bir plaka giriniz.');
        return;
      }

      final response = await CarRepairLogApi()
          .getLogsByLicensePlate(_plateController.text.trim().toUpperCase());

      if (response.status == 'success' && response.data!.isNotEmpty) {
        setState(() {
          filteredReports = List<CarRepairLogResponseDTO>.from(response.data!);
        });
      } else {
        setState(() {
          filteredReports = [];
        });
        StringHelper.showErrorDialog(context, 'Kayıt bulunamadı.');
      }
    }else if (selectedFilter == 'Görev Durumu') {
      if (selectedStatus == null) {
        StringHelper.showErrorDialog(context, 'Lütfen görev durumunu seçin.');
        return;
      } else {
        final response = await CarRepairLogApi().getLatestLogByTaskStatusName(selectedStatus!);
        if (response.status == 'success') {
          setState(() {
            filteredReports = List<CarRepairLogResponseDTO>.from(response.data!); // اینجا اصلاح شد
          });
        } else {
          setState(() {
            filteredReports = [];
          });
          StringHelper.showErrorDialog(context, response.message!);
        }
      }
    } else {
      StringHelper.showErrorDialog(context, 'Lütfen filtre türü seçin.');
    }
  }

  void ShowDetailsDialog(CarRepairLogResponseDTO log)async{
    StringHelper.ShowDetailsLogDialog(context, log);

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtre Türü:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedFilter,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            hint: const Text('Filtre türü seçin'),
            items: filterOptions
                .map(
                  (filter) => DropdownMenuItem<String>(
                value: filter,
                child: Text(filter),
              ),
            )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedFilter = value;
                _plateController.clear();
                selectedStatus = null;
                filteredReports.clear();
              });
            },
          ),
          const SizedBox(height: 16),

          if (selectedFilter == 'Plaka') ...[
            const Text('Araç Plakası:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _plateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Örneğin 12ABC345',
              ),
            ),
          ] else if (selectedFilter == 'Görev Durumu') ...[
            if (taskStatuses.isEmpty) ...[
              const SizedBox(height: 8),
              const Text('Görev durumları yükleniyor...',
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ] else ...[
              const Text('Görev Durumu:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Durum seçin'),
                items: taskStatuses
                    .map(
                      (status) => DropdownMenuItem<String>(
                    value: status.taskStatusName,
                    child: Text(status.taskStatusName),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                    filteredReports.clear();
                  });
                },

              ),
            ],
          ],

          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _filter_handler,
              child: const Text('Filtreyi Uygula'),
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: filteredReports.isEmpty
                ? const Center(
              child: Text('Kayıt bulunamadı veya filtre uygulanmadı.'),
            )
                : ListView.builder(
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final log = filteredReports[index];

                final licensePlate =
                    log.carInfo?.licensePlate ?? 'Bilinmiyor';
                final creatorName =
                "${log.creatorUser?.firstName ?? ''} ${log.creatorUser?.lastName ?? ''}".trim();
                final summary = log.problemReport?.problemSummary ?? 'Açıklama yok';
                final dateStr =
                log.dateTime.toString().split('.')[0];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text('Plaka: $licensePlate'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Araç: ${log.carInfo?.brand ?? '-'} ${log.carInfo?.brandModel ?? '-'}'),
                        Text('Oluşturan: $creatorName'),
                        Text('Tarih: $dateStr'),
                        Text('Durum: ${log.taskStatus?.taskStatusName ?? '-'}'),
                      ],
                    ),
                    trailing: statusSvgMap.containsKey(log.taskStatus?.taskStatusName)
                        ? SvgPicture.asset(
                      statusSvgMap[log.taskStatus!.taskStatusName]!,
                      width: 50,
                      height: 50,
                    )
                        : null,
                    onTap: () {
                      ShowDetailsDialog(log);
                    },
                  ),
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}
