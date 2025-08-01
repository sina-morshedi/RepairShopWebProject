import 'dart:async';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import '../features/dashboard/models/CarRepairLogResponseDTO.dart';
import '../features/dashboard/models/TaskStatusDTO.dart';
import '../utils/helpers/app_helpers.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../features/dashboard/backend_services/backend_services.dart';
import '../features/dashboard/models/TaskStatusUserRequestDTO.dart';
import '../features/dashboard/models/CarRepairLogRequestDTO.dart';
import '../features/dashboard/models/UserProfileDTO.dart';
import '../features/dashboard/models/PartUsed.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../features/dashboard/models/InventoryItemDTO.dart';
import '../features/dashboard/models/InventoryTransactionRequestDTO.dart';
import '../features/dashboard/models/InventoryChangeRequestDTO.dart';
import '../features/dashboard/models/InventoryTransactionResponseDTO.dart';
import '../features/dashboard/models/InventoryTransactionType.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../features/dashboard/controllers/UserController.dart';
import 'package:get/get.dart';
import 'RepairmanPartCard.dart';

class RepairmanWorkespaceInFlow extends StatefulWidget {
  final UserProfileDTO user;
  final String? plate;
  final VoidCallback? onConfirmed;

  const RepairmanWorkespaceInFlow({
    Key? key,
    required this.user,
    this.plate,
    this.onConfirmed,
  }) : super(key: key);

  @override
  State<RepairmanWorkespaceInFlow> createState() =>
      _RepairmanWorkespaceInFlowState();
}

class _RepairmanWorkespaceInFlowState extends State<RepairmanWorkespaceInFlow> {
  final userController = Get.find<UserController>();
  late UserProfileDTO user;
  final Map<String, String> statusSvgMap = const {
    'GÖREV YOK': 'assets/images/vector/stop.svg',
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'USTA': 'assets/images/vector/repairman.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'İŞ BİTTİ': 'assets/images/vector/finish-flag.svg',
    'FATURA': 'assets/images/vector/bill.svg',
  };

  List<Map<String, dynamic>> cars = [];
  final TextEditingController _pauseReasonController = TextEditingController();

  Map<int, TextEditingController> newPartControllers = {};
  Map<int, TextEditingController> newBarcodControllers = {};

  List<TextEditingController> partNames = [TextEditingController()];

  Map<int, List<TextEditingController>> partNameControllers = {};
  Map<int, List<TextEditingController>> quantityControllers = {};
  Map<int, List<TextEditingController>> unitPriceControllers = {};

  // اینجا نگهداری نتایج جستجو autocomplete است: [ماشین][قطعه] => لیست پیشنهادات
 Map<int, List<InventoryItemDTO>> partSearchResults = {};

  List<CarRepairLogResponseDTO>? logs;

  Timer? _debounce;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _loadCarsFromBackend();
    print('init');
  }

  @override
  void dispose() {
    for (var list in partNameControllers.values) {
      for (var c in list) {
        c.dispose();
      }
    }
    for (var list in quantityControllers.values) {
      for (var c in list) {
        c.dispose();
      }
    }
    _pauseReasonController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // void addNewPart(String partName) {
  //   if (partName.trim().isEmpty) return;
  //   setState(() {
  //     partNames.add(TextEditingController(text: partName));
  //     newPartController.clear();
  //   });
  // }

  Future<void> _loadCarsFromBackend() async {
    final request = TaskStatusUserRequestDTO(
      assignedUserId: user.userId,
      taskStatusNames: ["BAŞLANGIÇ", "DURAKLAT"],
    );

    print('widget.plate');
    print(widget.plate!);
    if(widget.plate == null || widget.plate!.isEmpty){
      StringHelper.showErrorDialog(context, 'Bu plaka numarası bulunamadı.');
      return;
    }


    final response =
        await CarRepairLogApi().getLatestLogByLicensePlate(widget.plate!);

    if (response.status == 'success') {
      print('response.data');
      print(response.data);
      logs = [response.data!];
      print('logs');
      print(logs);
      final loadedCars = logs!.map<Map<String, dynamic>>((log) {
        final car = log.carInfo;
        return {
          "licensePlate": car.licensePlate,
          "brand": car.brand,
          "model": car.brandModel,
          "year": car.modelYear.toString(),
          "taskStatusName": log.taskStatus.taskStatusName,
          "isExpanded": false,
        };
      }).toList();

      setState(() {
        cars = loadedCars;
        partNameControllers.clear();
        quantityControllers.clear();
        partSearchResults.clear();

        for (int i = 0; i < cars.length; i++) {
          final log = logs![i];
          final partsUsed = log.partsUsed;

          if (partsUsed != null && partsUsed.isNotEmpty) {
            partNameControllers[i] = partsUsed
                .map((p) => TextEditingController(text: p.partName))
                .toList();

            quantityControllers[i] = partsUsed
                .map((p) => TextEditingController(text: p.quantity.toString()))
                .toList();
            unitPriceControllers[i] = partsUsed
                .map((p) => TextEditingController(text: p.partPrice.toString()))
                .toList();
            newPartControllers[i] = TextEditingController();
            newBarcodControllers[i] = TextEditingController();
          } else {
            partNameControllers[i] = [TextEditingController()];
            quantityControllers[i] = [TextEditingController(text: "1")];
            unitPriceControllers[i] = [TextEditingController(text: "1")];
          }

          // مقداردهی اولیه لیست پیشنهادات برای هر قطعه خالی است
          partSearchResults[i] = [];

        }
      });
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  Future<void> addPartFieldBySearchBarcode(int index, String barcode) async{
    final part = await InventoryApi().getItemByBarcode(barcode);
    if(part.status != 'success'){
      StringHelper.showErrorDialog(context, part.message!);
      return;
    }
    print('price');
    print(part);
    setState(() {
      if (!partNameControllers.containsKey(index) || partNameControllers[index] == null) {
        partNameControllers[index] = <TextEditingController>[];
        quantityControllers[index] = <TextEditingController>[];
        unitPriceControllers[index] = <TextEditingController>[];
        partSearchResults = <int, List<InventoryItemDTO>>{};
      }

      final controllers = partNameControllers[index]!;

      // اگر لیست کنترلرها خالیه یا فقط یک کنترلر با مقدار خالی داره
      if (controllers.isEmpty ||
          (controllers.length == 1 && controllers[0].text.trim().isEmpty)) {
        // کنترلر اول رو مقداردهی کن
        if (controllers.isEmpty) {

          // اگه خالی بود، ابتدا یه کنترلر جدید اضافه کن
          controllers.add(TextEditingController(text: part.data!.partName));
          quantityControllers[index]!.add(TextEditingController(text: "1"));
          unitPriceControllers[index]!.add(TextEditingController(text: '${part.data!.salePrice}'));
          partSearchResults[index] = [];
        } else {
          // اگه یک کنترلر هست ولی خالی، مقدارش رو ست کن
          controllers[0].text = part.data!.partName;
          unitPriceControllers[index]![0].text = '${part.data!.salePrice}';
        }
      } else {
        // کارت جدید اضافه کن
        controllers.add(TextEditingController(text: part.data!.partName));
        quantityControllers[index]!.add(TextEditingController(text: "1"));
        unitPriceControllers[index]!.add(TextEditingController(text: '${part.data!.salePrice}'));
        partSearchResults[index] = [];
      }
    });
    newPartControllers[index]?.clear();
    newBarcodControllers[index]?.clear();
  }

  Future<void> addPartFieldBySearchName(int index, String part) async{
    final price = await _fetchSalePriceForPart(part);
    print('price');
    print(price);
    setState(() {
      if (!partNameControllers.containsKey(index) || partNameControllers[index] == null) {
        partNameControllers[index] = <TextEditingController>[];
        quantityControllers[index] = <TextEditingController>[];
        unitPriceControllers[index] = <TextEditingController>[];
        partSearchResults = <int, List<InventoryItemDTO>>{};
      }

      final controllers = partNameControllers[index]!;

      // اگر لیست کنترلرها خالیه یا فقط یک کنترلر با مقدار خالی داره
      if (controllers.isEmpty ||
          (controllers.length == 1 && controllers[0].text.trim().isEmpty)) {
        // کنترلر اول رو مقداردهی کن
        if (controllers.isEmpty) {

          // اگه خالی بود، ابتدا یه کنترلر جدید اضافه کن
          controllers.add(TextEditingController(text: part));
          quantityControllers[index]!.add(TextEditingController(text: "1"));
          unitPriceControllers[index]!.add(TextEditingController(text: '$price'));
          partSearchResults[index] = [];
        } else {
          // اگه یک کنترلر هست ولی خالی، مقدارش رو ست کن
          controllers[0].text = part;
          unitPriceControllers[index]![0].text = '$price';
        }
      } else {
        // کارت جدید اضافه کن
        controllers.add(TextEditingController(text: part));
        quantityControllers[index]!.add(TextEditingController(text: "1"));
        unitPriceControllers[index]!.add(TextEditingController(text: '$price'));
        partSearchResults[index] = [];
      }
    });
    newPartControllers[index]?.clear();
    newBarcodControllers[index]?.clear();
  }

  // void addPartField(int index) {
  //   setState(() {
  //     partNameControllers[index]!.add(TextEditingController());
  //     quantityControllers[index]!.add(TextEditingController(text: "1"));
  //     partSearchResults[index] = [];
  //   });
  // }

  void removePartField(int index, int partIndex) {
    setState(() {
      if (partNameControllers[index]!.length > 1) {
        partNameControllers[index]![partIndex].dispose();
        quantityControllers[index]![partIndex].dispose();
        partNameControllers[index]!.removeAt(partIndex);
        quantityControllers[index]!.removeAt(partIndex);
        partSearchResults[index]!.remove(partIndex);

        // برای اصلاح ایندکس‌ها، کل map را دوباره تنظیم می‌کنیم:
        final newMap = <int, List<InventoryItemDTO>>{};
        for (int i = 0; i < partNameControllers[index]!.length; i++) {
          newMap[i] = partSearchResults[index] ?? [];
        }
        partSearchResults = newMap;
      }
    });
  }

  // متد جستجو با debounce
  void searchParts(int carIndex, String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.length < 2) {
        setState(() {
          partSearchResults[carIndex] = [];
        });
        return;
      }

      final response = await InventoryApi().getByPartName(query);
      if (response.status == 'success' && response.data != null) {
        final filtered = response.data!
            .where((item) =>
                item.partName.toLowerCase().contains(query.toLowerCase()))
            .toList();

        setState(() {
          partSearchResults[carIndex] = filtered;
        });
      } else {
        setState(() {
          partSearchResults[carIndex] = [];
        });
      }
    });
  }

  void _showPauseDialog(BuildContext context, int index) {
    _pauseReasonController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Görev Duraklaması Sebebi"),
        content: TextField(
          controller: _pauseReasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Lütfen duraklama sebebini yazınız",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              final reason = _pauseReasonController.text.trim();
              Navigator.of(ctx).pop();
              saveRepairLog(index, 'DURAKLAT', pauseReason: reason);
            },
            child: Text("Onayla"),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, int index, String action) {
    String actionLabel = action;
    switch (action) {
      case "Save":
        actionLabel = "Kaydet";
        break;
      case "Load":
        actionLabel = "Yükle";
        break;
      case "Finish Job":
        actionLabel = "İş Bitir";
        break;
      case "Approve Job":
        actionLabel = "Görev Duraklaması";
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("$actionLabel Onayı"),
        content: Text(
            "Araç için $actionLabel işlemini yapmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text("İptal")),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (action == "Save") {
                saveRepairLog(index, 'BAŞLANGIÇ');
              } else if (action == "Load") {
                loadRepairLog(index);
              } else if (action == "Finish Job") {
                saveRepairLog(index, 'İŞ BİTTİ');
              } else {}
            },
            child: Text("Onayla"),
          ),
        ],
      ),
    );
  }

  Future<void> loadRepairLog(int index) async {
    final currentLog = logs?[index];
    if (currentLog == null || currentLog.id == null) return;

    final response = await CarRepairLogApi().getLogByid(currentLog.id!);
    if (response.status == 'success' && response.data != null) {
      final updatedLog = response.data!;
      logs![index] = updatedLog;

      setState(() {
        cars[index] = {
          "licensePlate": updatedLog.carInfo.licensePlate,
          "brand": updatedLog.carInfo.brand,
          "model": updatedLog.carInfo.brandModel,
          "year": updatedLog.carInfo.modelYear.toString(),
          "taskStatusName": updatedLog.taskStatus.taskStatusName,
          "isExpanded": true,
        };

        partNameControllers[index] = updatedLog.partsUsed
                ?.map(
                  (p) => TextEditingController(text: p.partName),
                )
                .toList() ??
            [TextEditingController()];

        quantityControllers[index] = updatedLog.partsUsed
                ?.map(
                  (p) => TextEditingController(text: p.quantity.toString()),
                )
                .toList() ??
            [TextEditingController(text: "1")];

        // مقداردهی اولیه لیست پیشنهادات برای هر قطعه در حالت لود
        partSearchResults = {};
        for (int j = 0; j < partNameControllers[index]!.length; j++) {
          partSearchResults[index] = [];
        }
      });
    } else {
      StringHelper.showErrorDialog(
          context, response.message ?? "Sunucu hatası");
    }
  }

  Future<void> saveRepairLog(int index, String newTaskStatusName, {String? pauseReason}) async {
    try {
      setState(() {
        isSaving = true;
      });
      if (logs == null || index >= logs!.length) return;

      final log = logs![index];

      // ❌ جلوگیری از DURAKLAT → İŞ BİTTİ
      if (newTaskStatusName.toUpperCase() == 'İŞ BİTTİ' &&
          log.taskStatus.taskStatusName.toUpperCase() == 'DURAKLAT') {
        StringHelper.showErrorDialog(context,
            "Duraklatılmış bir görev doğrudan İŞ BİTTİ olarak işaretlenemez.");
        return;
      }

      final isPause = newTaskStatusName.toUpperCase() == 'DURAKLAT';

      final List<PartUsed> newPartsUsed = [];

      for (int i = 0; i < partNameControllers[index]!.length; i++) {
        final name = partNameControllers[index]![i].text.trim();
        final qtyStr = quantityControllers[index]![i].text.trim();

        if (name.isEmpty && qtyStr.isEmpty) {
          if (isPause) continue;
          continue;
        }

        if (name.isEmpty) {
          if (!isPause && newTaskStatusName.toUpperCase() != 'İŞ BİTTİ') {
            StringHelper.showErrorDialog(
                context, "Parça adı boş olamaz (satır ${i + 1})");
            return;
          }
          continue;
        }

        if (qtyStr.isEmpty) {
          if (!isPause) {
            StringHelper.showErrorDialog(
                context, "Adet bilgisi boş olamaz (satır ${i + 1})");
            return;
          }
          continue;
        }

        final qty = int.tryParse(qtyStr);
        if (qty == null || qty <= 0) {
          if (!isPause) {
            StringHelper.showErrorDialog(
                context, "Adet değeri geçersiz (satır ${i + 1})");
            return;
          }
          continue;
        }

        final price = await _fetchSalePriceForPart(name);
        newPartsUsed
            .add(PartUsed(partName: name, quantity: qty, partPrice: price));
      }

      // گرفتن وضعیت وظیفه
      TaskStatusDTO? matchingStatus;
      final responseTask =
          await TaskStatusApi().getTaskStatusByName(newTaskStatusName);
      if (responseTask.status == 'success') {
        matchingStatus = responseTask.data;
      } else {
        StringHelper.showErrorDialog(context, responseTask.message!);
        return;
      }

      final List<InventoryTransactionRequestDTO> transactionsToAdd = [];
      if (userController.isInventoryEnabled) {
        // تهیه دو لیست از قطعات قبلی و جدید
        final Map<String, int> oldPartsQty = {};
        if (log.partsUsed != null) {
          for (var part in log.partsUsed!) {
            oldPartsQty[part.partName] = part.quantity;
          }
        }

        final Map<String, int> newPartsQty = {};
        for (var part in newPartsUsed) {
          newPartsQty[part.partName] = part.quantity;
        }

        for (var entry in {...oldPartsQty.keys, ...newPartsQty.keys}) {
          final oldQty = oldPartsQty[entry] ?? 0;
          final newQty = newPartsQty[entry] ?? 0;
          final diff = newQty - oldQty;

          if (diff == 0) continue;

          final inventoryId = await getInventoryIdByName(entry);
          if (inventoryId == null) {
            StringHelper.showErrorDialog(
                context, "'$entry' için parça kimliği bulunamadı.");
            return;
          }

          final transactionType = diff > 0
              ? TransactionType.CONSUMPTION
              : TransactionType.RETURN_CONSUMPTION;

          final transactionDto = InventoryTransactionRequestDTO(
            creatorUserId: log.creatorUser.userId,
            inventoryItemId: inventoryId,
            quantity: diff.abs(),
            type: transactionType,
            description: diff > 0
                ? "Tamirhanede kullanım için alındı."
                : "Depoya iade edildi.",
            carInfoId: log.carInfo.id,
            customerId: log.customer?.id,
            dateTime: DateTime.now(),
          );

          transactionsToAdd.add(transactionDto);
        }
      }

      final dto = CarRepairLogRequestDTO(
        carId: log.carInfo.id,
        creatorUserId: log.creatorUser.userId,
        assignedUserId: log.assignedUser?.userId,
        description: pauseReason,
        taskStatusId: matchingStatus!.id!,
        dateTime: DateTime.now(),
        problemReportId: log.problemReport?.id,
        partsUsed: newPartsUsed.isEmpty ? null : newPartsUsed,
        customerId: log.customer?.id ?? "",
      );

      final response = matchingStatus.taskStatusName.toUpperCase() == 'İŞ BİTTİ'
          ? await CarRepairLogApi().createLog(dto)
          : await CarRepairLogApi().updateLog(log.id!, dto);

      if (response.status == 'success') {
        final updatedLog = response.data!;

        if (newTaskStatusName.toUpperCase() == 'İŞ BİTTİ') {
          logs!.removeAt(index);
          cars.removeAt(index);
          widget.onConfirmed?.call();
          _rebuildControllersAndSearchResults();

          setState(() {});
        } else {
          logs![index] = updatedLog;

          setState(() {
            cars[index] = {
              "licensePlate": updatedLog.carInfo.licensePlate,
              "brand": updatedLog.carInfo.brand,
              "model": updatedLog.carInfo.brandModel,
              "year": updatedLog.carInfo.modelYear.toString(),
              "taskStatusName": updatedLog.taskStatus.taskStatusName,
              "isExpanded": true,
            };

            partNameControllers[index] = updatedLog.partsUsed
                    ?.map(
                      (p) => TextEditingController(text: p.partName),
                    )
                    .toList() ??
                [TextEditingController()];

            quantityControllers[index] = updatedLog.partsUsed
                    ?.map(
                      (p) => TextEditingController(text: p.quantity.toString()),
                    )
                    .toList() ??
                [TextEditingController(text: "1")];

            partSearchResults = {};
            for (int j = 0; j < partNameControllers[index]!.length; j++) {
              partSearchResults[index] = [];
            }
          });
        }

        // اینجا اضافه کردم شرط چک کردن فعال بودن اینونتوری
        if (userController.isInventoryEnabled) {
          final inventoryApi = InventoryTransactionApi();

          for (var transaction in transactionsToAdd) {
            final transactionResponse =
                await inventoryApi.addTransaction(transaction);
            if (transactionResponse.status != 'success') {
              StringHelper.showErrorDialog(
                  context, transactionResponse.message!);
            } else {
              final changeRequest = InventoryChangeRequestDTO(
                itemId: transaction.inventoryItemId,
                amount: transaction.quantity,
                updatedAt: DateTime.now(),
                creatorUserId: log.creatorUser.userId,
              );

              if (transaction.type == TransactionType.RETURN_CONSUMPTION) {
                final incrementResponse =
                    await InventoryApi().incrementQuantity(changeRequest);
                if (incrementResponse.status != 'success') {
                  StringHelper.showErrorDialog(context,
                      'Envanter artırma işlemi başarısız oldu: ${incrementResponse.message}');
                }
              } else if (transaction.type == TransactionType.CONSUMPTION) {
                final decrementResponse =
                    await InventoryApi().decrementQuantity(changeRequest);
                if (decrementResponse.status != 'success') {
                  StringHelper.showErrorDialog(context,
                      'Envanter azaltma işlemi başarısız oldu: ${decrementResponse.message}');
                }
              }
            }
          }
        } else {
          // inventory غیرفعال است، پس تراکنش‌ها ثبت نمی‌شوند
          debugPrint("Inventory is disabled; skipping inventory transactions.");
        }

        StringHelper.showInfoDialog(
            context, "Bilgiler başarıyla faturaya kaydedildi.");
      } else {
        StringHelper.showErrorDialog(context, response.message!);
      }
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }
//------------------------------------------------------------
  Future<double> _fetchSalePriceForPart(String partName) async {
    if (!userController.isInventoryEnabled) {
      debugPrint("Inventory disabled; returning 0 price for part $partName");
      return 0.0;
    }
    try {
      final response = await InventoryApi().getByPartName(partName);

      if (response.status == 'success' && response.data != null) {
        return response.data!.first.salePrice ?? 0.0;
      }
    } catch (e) {
      debugPrint("Error fetching sale price: $e");
    }
    return 0.0;
  }

  Future<String?> getInventoryIdByName(String name) async {
    print(
        'userController.isInventoryEnabled: ${userController.isInventoryEnabled}');
    if (!userController.isInventoryEnabled) {
      debugPrint("Inventory disabled; cannot get inventory ID for $name");
      return null;
    }
    final response = await InventoryApi().getByPartName(name);
    if (response.status == 'success' &&
        response.data != null &&
        response.data!.isNotEmpty) {
      return response.data!.first.id; // فرض بر اینه که اولین آیتم درست باشه
    } else {
      return null;
    }
  }

  void _rebuildControllersAndSearchResults() {
    final newPartNameControllers = <int, List<TextEditingController>>{};
    final newQuantityControllers = <int, List<TextEditingController>>{};
    final newPartSearchResults = <int, Map<int, List<InventoryItemDTO>>>{};

    // Dispose کنترلرهای قدیمی که دیگه تو newMap نیستند
    final removedKeys =
        partNameControllers.keys.where((key) => key >= logs!.length).toList();
    for (var key in removedKeys) {
      for (var ctrl in partNameControllers[key]!) {
        ctrl.dispose();
      }
      partNameControllers.remove(key);
    }
    final removedQtyKeys =
        quantityControllers.keys.where((key) => key >= logs!.length).toList();
    for (var key in removedQtyKeys) {
      for (var ctrl in quantityControllers[key]!) {
        ctrl.dispose();
      }
      quantityControllers.remove(key);
    }
    partSearchResults.removeWhere((key, value) => key >= logs!.length);

    // بازسازی Mapها با داده‌های جدید با ایندکس مرتب
    for (int i = 0; i < logs!.length; i++) {
      final log = logs![i];

      // ایجاد کنترلر جدید برای قطعات لاگ i
      final partsUsed = log.partsUsed;
      if (partsUsed != null && partsUsed.isNotEmpty) {
        newPartNameControllers[i] = partsUsed
            .map((p) => TextEditingController(text: p.partName))
            .toList();
        newQuantityControllers[i] = partsUsed
            .map((p) => TextEditingController(text: p.quantity.toString()))
            .toList();
      } else {
        newPartNameControllers[i] = [TextEditingController()];
        newQuantityControllers[i] = [TextEditingController(text: "1")];
      }

      // newPartSearchResults[i] = {};
      // for (int j = 0; j < newPartNameControllers[i]!.length; j++) {
      //   newPartSearchResults[i]![j] = [];
      // }
    }

    // دیسپوز کنترلرهای قدیمی که دیگه تو newMap نیستند
    for (final key in partNameControllers.keys) {
      if (!newPartNameControllers.containsKey(key)) {
        for (final ctrl in partNameControllers[key]!) {
          ctrl.dispose();
        }
      }
    }
    for (final key in quantityControllers.keys) {
      if (!newQuantityControllers.containsKey(key)) {
        for (final ctrl in quantityControllers[key]!) {
          ctrl.dispose();
        }
      }
    }

    partNameControllers = newPartNameControllers;
    quantityControllers = newQuantityControllers;
    // partSearchResults = newPartSearchResults;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxHeight: 600, // یا هر محدودیت دلخواهی
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, carIndex) {
                    final car = cars[carIndex];
                    final isExpanded = car["isExpanded"] as bool? ?? false;

                    partNames =
                        partNameControllers.containsKey(carIndex) &&
                                partNameControllers[carIndex] != null
                            ? partNameControllers[carIndex]!
                            : <TextEditingController>[];

                    final partSearchMap =
                        partSearchResults.containsKey(carIndex) &&
                                partSearchResults[carIndex] != null
                            ? partSearchResults[carIndex]!
                            : <int, List<InventoryItemDTO>>{};

                    return GestureDetector(
                      onTap: () =>
                          setState(() => car["isExpanded"] = !isExpanded),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isExpanded
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Plaka: ${car['licensePlate']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Marka: ${car['brand']}"),
                                  Text("Model: ${car['model']}"),
                                  Text("Yıl: ${car['year']}"),
                                  const SizedBox(height: 8),

                                  SizedBox(height: 50),

                                  Column(
                                    children: [
                                      TextField(
                                        controller: newPartControllers[carIndex],
                                        decoration: InputDecoration(
                                          labelText: "Parça ekle",
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          searchParts(carIndex, value); // حذف اون پارامتر وسطی چون دیگه index نداری
                                        },
                                        onSubmitted: (value) {
                                          addPartFieldBySearchName(carIndex, value);
                                          newPartControllers[carIndex]?.clear();
                                          setState(() {
                                            partSearchResults[carIndex] = [];
                                          });
                                        },
                                      ),

                                      const SizedBox(height: 6),

                                      ...partSearchResults[carIndex]?.map((item) => ListTile(
                                        title: Text(item.partName),
                                        onTap: () {
                                          addPartFieldBySearchName(carIndex, item.partName);
                                          newPartControllers[carIndex]?.clear();
                                          setState(() {
                                            partSearchResults[carIndex] = [];
                                          });
                                        },
                                      )).toList() ?? [],

                                      TextField(
                                        controller: newBarcodControllers[carIndex],
                                        decoration: InputDecoration(
                                          labelText: "Parça ekle",
                                          border: OutlineInputBorder(),
                                        ),
                                        onSubmitted: (value) {
                                          addPartFieldBySearchBarcode(carIndex, value);
                                          newPartControllers[carIndex]?.clear();
                                          setState(() {
                                            partSearchResults[carIndex] = [];
                                          });
                                        },
                                      ),

                                      const SizedBox(height: 6),

                                      ...partSearchResults[carIndex]?.map((item) => ListTile(
                                        title: Text(item.partName),
                                        onTap: () {
                                          addPartFieldBySearchName(carIndex, item.partName);
                                          newPartControllers[carIndex]?.clear();
                                          setState(() {
                                            partSearchResults[carIndex] = [];
                                          });
                                        },
                                      )).toList() ?? [],


                                      const SizedBox(height: 12),
                                      ...List.generate(partNames.length, (partIndex) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            RepairmanPartCard(
                                              partNameController: partNameControllers[carIndex]![partIndex],
                                              quantityController: quantityControllers[carIndex]![partIndex],
                                              unitPriceController: unitPriceControllers[carIndex]![partIndex],
                                              onRemovePressed: () {
                                                removePartField(carIndex, partIndex);
                                              },
                                            ),
                                          ],
                                        );
                                      }),

                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _showConfirmDialog(
                                              context, carIndex, "Save"),
                                          child: const Text("Kaydet"),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: () => _showConfirmDialog(
                                              context, carIndex, "Load"),
                                          child: const Text("Yükle"),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: () => _showConfirmDialog(
                                              context, carIndex, "Finish Job"),
                                          child: const Text("İş Bitir"),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: () => _showPauseDialog(
                                              context, carIndex),
                                          child: const Text("Görev Duraklat"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        statusSvgMap[car['taskStatusName']] ??
                                            'assets/images/vector/stop.svg',
                                        width: 32,
                                        height: 32,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "${car['licensePlate']} - ${car['taskStatusName']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Icon(isExpanded
                                      ? MdiIcons.chevronUp
                                      : MdiIcons.chevronDown)
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (isSaving) ...[
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
