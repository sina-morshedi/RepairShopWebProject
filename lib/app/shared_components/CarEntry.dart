import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CustomerDTO.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'CustomerInfoCard.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';

class CarEntry extends StatefulWidget {
  final String? initialPlate;
  final VoidCallback? onEntrySuccess;

  const CarEntry({super.key, this.initialPlate, this.onEntrySuccess});

  @override
  State<CarEntry> createState() => _CarEntryState();
}

class _CarEntryState extends State<CarEntry> {
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();

  CarInfoDTO? carData;
  List<CustomerDTO>? customerData;
  CustomerDTO? selectedCustomer;

  CarInfoDTO? selectedCar;
  CarRepairLogResponseDTO? latestLog;
  TaskStatusDTO? taskStatusLog;
  bool isLoading = false;
  bool foundLog = false;

  bool isSaving = false;

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
    if (widget.initialPlate != null && widget.initialPlate!.isNotEmpty) {
      _plateController.text = widget.initialPlate!.toUpperCase();
      _searchPlate();
    }
  }


  Future<void> _searchPlate() async {
    final plate = _plateController.text.trim().toUpperCase();
    if (plate.isEmpty) return;

    setState(() {
      isLoading = true;
      selectedCar = null;
      latestLog = null;
    });

    final carResponse = await CarInfoApi().getCarInfoByLicensePlate(plate);

    setState(() => isLoading = false);

    if (carResponse.status == 'success') {
      selectedCar = carResponse.data;
    } else {
      StringHelper.showErrorDialog(
          context, carResponse.message!);
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
          context, logResponse.message!);
    }

    final taskStatus = await TaskStatusApi().getTaskStatusByName('GİRMEK');
    if (taskStatus.status == 'success') {
      setState(() {
        taskStatusLog = taskStatus.data;
      });
    } else {
      StringHelper.showErrorDialog(context, taskStatus.message!);
    }
  }

  void _searchCustomer() async {
    final name = _customerNameController.text.trim();
    if (name.isEmpty) return;

    final response = await CustomerApi().searchCustomerByName(name);

    if (response.status == 'success') {
      setState(() {
        customerData = response.data!;
      });
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  Future<void> _submitEntry() async {
    final userController = Get.find<UserController>();
    final userId = userController.currentUser?.userId ?? "";

    if (selectedCustomer == null) {
      StringHelper.showErrorDialog(context, "Lütfen bir müşteri seçiniz.");
      return;
    }
    if (selectedCar != null) {
      setState(() {
        isSaving = true;
      });

      final logRequest = CarRepairLogRequestDTO(
        carId: selectedCar!.id,
        creatorUserId: userId,
        description: '',
        taskStatusId: taskStatusLog!.id!,
        dateTime: DateTime.now(),
        problemReportId: null,
        customerId: selectedCustomer!.id,
      );

      final response = await CarRepairLogApi().createLog(logRequest);

      setState(() {
        isSaving = false;
      });

      if (response.status == 'success' && response.data != null) {
        foundLog = true;
        setState(() {
          latestLog = response.data;
        });

        StringHelper.showInfoDialog(context, 'Araba girişi kaydedildi');
        widget.onEntrySuccess?.call();
      } else
        StringHelper.showErrorDialog(context, response.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.initialPlate == null) ...[
                TextField(
                  controller: _plateController,
                  onSubmitted: (_) => _searchPlate(),
                  decoration: InputDecoration(
                    labelText: 'Plaka giriniz',
                    suffixIcon: IconButton(
                      icon: const Icon(EvaIcons.search),
                      onPressed: _searchPlate,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),

              if (selectedCar != null) CarInfoCard(car: selectedCar!),

              const SizedBox(height: 24),

              if (latestLog == null || latestLog!.taskStatus.taskStatusName == "GÖREV YOK") ...[
                if (selectedCar != null) ...[
                  TextField(
                    controller: _customerNameController,
                    onSubmitted: (_) => _searchCustomer(),
                    decoration: InputDecoration(
                      labelText: 'Müşteri adı',
                      suffixIcon: IconButton(
                        icon: const Icon(EvaIcons.search),
                        onPressed: _searchCustomer,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                if (customerData != null && customerData!.isNotEmpty)
                  CustomerListCard(
                    customers: customerData!,
                    selectedCustomer: selectedCustomer,
                    onSelected: (c) => setState(() => selectedCustomer = c),
                  ),

                const SizedBox(height: 24),

                if (selectedCar != null)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (selectedCustomer == null) {
                          StringHelper.showErrorDialog(context, 'Lütfen bir müşteri seçiniz.');
                          return;
                        }

                        if (!foundLog || latestLog!.taskStatus.taskStatusName == 'GÖREV YOK') {
                          _submitEntry();
                        } else {
                          StringHelper.showErrorDialog(context, 'Araba şu anda tamir aşamasında.');
                        }
                      },
                      icon: const Icon(EvaIcons.logIn),
                      label: const Text('Araç girişi'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                const SizedBox(height: 16),
                SvgPicture.asset(
                  statusSvgMap[latestLog!.taskStatus.taskStatusName] ?? 'assets/images/vector/stop.svg',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(height: 16),
                Text('Görev Durumu: ${latestLog!.taskStatus.taskStatusName}'),
              ],
            ],
          ),
        ),

        // لودینگ ذخیره
        if (isSaving) ...[
          Positioned.fill(
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

// کارت ماشین با آیکون ماشین ساده EvaIcons.car
class CarInfoCard extends StatelessWidget {
  final CarInfoDTO car;

  const CarInfoCard({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    'Plaka: ${car.licensePlate}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText('Marka: ${car.brand} ${car.brandModel}'),
                  SelectableText('Model Yılı: ${car.modelYear}'),
                  SelectableText('Yakıt Tipi: ${car.fuelType}'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              EvaIcons.car,
              size: 48,
              color: Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }
}
