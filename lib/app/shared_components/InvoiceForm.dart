import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/shared_components/CarRepairedLogCard.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:universal_html/html.dart' as html;
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:repair_shop_web/app/features/dashboard/models/PartUsed.dart';

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({super.key});

  @override
  _InvoiceFormState createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  pw.Font? customFont;
  pw.MemoryImage? logoImage;
  final TextEditingController _plateController = TextEditingController();
  CarRepairLogResponseDTO? log;

  List<PartUsed> parts = [];
  List<double> totalPice = [];

  // کنترلرهای متن برای هر ردیف
  final List<TextEditingController> nameControllers = [];
  final List<TextEditingController> quantityControllers = [];
  final List<TextEditingController> priceControllers = [];
  final List<TextEditingController> totalPriceControllers = [];

  @override
  void initState() {
    super.initState();
    loadAssets();
  }

  @override
  void dispose() {
    _plateController.dispose();
    for (var c in nameControllers) {
      c.dispose();
    }
    for (var c in quantityControllers) {
      c.dispose();
    }
    for (var c in priceControllers) {
      c.dispose();
    }
    for (var c in totalPriceControllers) c.dispose();
    super.dispose();
  }

  void _syncControllersWithParts() {
    // پاک کردن کنترلرهای قدیمی
    for (var c in nameControllers) {
      c.dispose();
    }
    for (var c in quantityControllers) {
      c.dispose();
    }
    for (var c in priceControllers) {
      c.dispose();
    }
    for (var c in totalPriceControllers) {
      c.dispose();
    }
    nameControllers.clear();
    quantityControllers.clear();
    priceControllers.clear();
    totalPriceControllers.clear();

    // ساخت کنترلر جدید بر اساس parts
    for (var part in parts) {
      nameControllers.add(TextEditingController(text: part.partName));
      quantityControllers.add(TextEditingController(text: part.quantity.toString()));
      priceControllers.add(TextEditingController(text: part.partPrice.toStringAsFixed(0)));
      totalPriceControllers.add(TextEditingController(text: (part.quantity * part.partPrice).toStringAsFixed(0)));
    }
  }

  Future<void> loadAssets() async {
    final fontData = await rootBundle.load("assets/fonts/Vazirmatn-Regular.ttf");
    final imageData = await rootBundle.load("images/logo.png");

    setState(() {
      customFont = pw.Font.ttf(fontData);
      logoImage = pw.MemoryImage(imageData.buffer.asUint8List());
    });
  }

  Future<void> _searchByPlate() async {
    final plate = _plateController.text.trim().toUpperCase();
    if (plate.isEmpty) return;

    final response = await CarRepairLogApi().getLatestLogByLicensePlate(plate);
    if (response.status == 'success') {
      setState(() {
        log = response.data;
      });

      final partUsedList = response.data!.partsUsed;
      if(response.data!.taskStatus.taskStatusName != "İŞ BİTTİ"
          && response.data!.taskStatus.taskStatusName != "FATURA"){
        StringHelper.showErrorDialog(context, "${plate} numaralı plakanın işi henüz bitmedi");
        return;
      }
      if (partUsedList != null && partUsedList.isNotEmpty) {
        parts = partUsedList.map((part) {
          final price = part.partPrice?.toDouble() ?? 0.0;
          final validPrice = (price < 0) ? 0.0 : price;
          return PartUsed(
            partName: part.partName ?? '',
            partPrice: validPrice,
            quantity: part.quantity ?? 1,
          );
        }).toList();
      } else {
        // اگر partsUsed خالی بود، می‌تونید مقدار پیش‌فرض بذارید یا کاری نکنید
        parts = [];
      }
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }

    _syncControllersWithParts();

  }


  Future<void> _generateAndDownloadPdf() async {
    if (customFont == null || logoImage == null) return;

    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate =
        "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
    final invoiceNumber = "INV-${now.year}${now.month}${now.day}-001";
    final customerName = "Ahmet Muhammet";
    final licensePlate = _plateController.text.trim();
    final total = parts.fold<double>(0, (sum, part) => sum + part.total);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Image(logoImage!, width: 350, height: 350),
                ),
                pw.SizedBox(height: 16),
                pw.Text("Servis Faturası",
                    style: pw.TextStyle(fontSize: 24, font: customFont)),
                pw.SizedBox(height: 16),
                pw.Text("Fatura Numarası: $invoiceNumber",
                    style: pw.TextStyle(font: customFont)),
                pw.Text("Tarih: $formattedDate",
                    style: pw.TextStyle(font: customFont)),
                pw.Text("Müşteri Adı: $customerName",
                    style: pw.TextStyle(font: customFont)),
                pw.Text("Plaka: $licensePlate",
                    style: pw.TextStyle(font: customFont)),
                pw.SizedBox(height: 24),
                pw.Text("Parça Listesi:",
                    style: pw.TextStyle(fontSize: 18, font: customFont)),
                pw.Table.fromTextArray(
                  headers: ['#', 'Parça Adı', 'Adet', 'Birim Fiyat', 'Toplam'],
                  data: List.generate(parts.length, (index) {
                    final part = parts[index];
                    return [
                      (index + 1).toString(),
                      part.partName,
                      part.quantity.toString(),
                      part.partPrice.toStringAsFixed(0),
                      part.total.toStringAsFixed(0),
                    ];
                  }),
                  cellStyle: pw.TextStyle(font: customFont),
                  headerStyle: pw.TextStyle(
                      font: customFont, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Toplam: ${total.toStringAsFixed(0)} TL",
                      style: pw.TextStyle(fontSize: 16, font: customFont)),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "$invoiceNumber.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _updateLog()async{
    final UserController userController = Get.find<UserController>();
    final user = userController.user.value;
    final responseTask = await TaskStatusApi().getTaskStatusByName('FATURA');
    if(responseTask.status != 'success'){
      StringHelper.showErrorDialog(context, responseTask.message!);
      return;
    }
    if(log!.taskStatus.taskStatusName != 'FATURA'){
      final request = CarRepairLogRequestDTO(
          carId: log!.carInfo.id,
          creatorUserId: user!.userId,
          assignedUserId: log!.assignedUser!.userId,
          description: log!.description,
          taskStatusId: responseTask.data!.id!,
          problemReportId: log!.problemReport!.id,
          partsUsed: parts,
          dateTime: DateTime.now()
      );
      final response = await CarRepairLogApi().createLog(request);
      if(response.status == 'success') {
        StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
        _searchByPlate();
      } else
        StringHelper.showErrorDialog(context, response.message!);
    }else{
      final request = CarRepairLogRequestDTO(
          carId: log!.carInfo.id,
          creatorUserId: user!.userId,
          assignedUserId: log!.assignedUser!.userId,
          description: log!.description,
          taskStatusId: log!.taskStatus!.id!,
          problemReportId: log!.problemReport!.id,
          partsUsed: parts,
          dateTime: DateTime.now()
      );
      final response = await CarRepairLogApi().updateLog(log!.id!, request);
      if(response.status == 'success') {
        StringHelper.showInfoDialog(context, response.message!);
        _searchByPlate();
      } else
        StringHelper.showErrorDialog(context, response.message!);
    }
  }


  Widget buildPartsInputList() {
    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ...parts.asMap().entries.map((entry) {
          final index = entry.key;
          final part = entry.value;

          return Padding(
            key: ValueKey(part),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Column(
                  children: [
                    if (index == parts.length - 1) ...[
                      IconButton(
                        icon: const Icon(EvaIcons.plusCircleOutline, color: Colors.green),
                        tooltip: "Yeni Parça Ekle",
                        onPressed: () {
                          parts.insert(index + 1, PartUsed(partName: '', partPrice: 0, quantity: 1));
                          _syncControllersWithParts();
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(EvaIcons.closeCircleOutline, color: Colors.red),
                        tooltip: "Bu Parçayı Sil",
                        onPressed: () {
                          parts.removeAt(index);
                          _syncControllersWithParts();
                          setState(() {});
                        },
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(EvaIcons.closeCircleOutline, color: Colors.red),
                        tooltip: "Bu Parçayı Sil",
                        onPressed: () {
                          parts.removeAt(index);
                          _syncControllersWithParts();
                          setState(() {});
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 7,
                  child: TextFormField(
                    controller: nameControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Parça Adı',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      parts[index] = PartUsed(
                        partName: val,
                        partPrice: parts[index].partPrice,
                        quantity: parts[index].quantity,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: quantityControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Adet',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final newQty = int.tryParse(value) ?? 1;
                      parts[index] = PartUsed(
                        partName: parts[index].partName,
                        partPrice: parts[index].partPrice,
                        quantity: newQty,
                      );
                      totalPriceControllers[index].text = (newQty * parts[index].partPrice).toString();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: priceControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'Birim Fiyat',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final newPrice = double.tryParse(val) ?? 0;
                      parts[index] = PartUsed(
                        partName: parts[index].partName,
                        partPrice: newPrice,
                        quantity: parts[index].quantity,
                      );
                      totalPriceControllers[index].text = (parts[index].quantity * newPrice).toString();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: totalPriceControllers[index],
                    readOnly: true,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'Toplam',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: () {
            _updateLog();
          },
          child: const Text('Faturayı Güncelle'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: "Plaka Numarası",
                suffixIcon: IconButton(
                  icon: const Icon(EvaIcons.search),
                  onPressed: _searchByPlate,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: (customFont == null || logoImage == null || parts.isEmpty)
                  ? null
                  : _generateAndDownloadPdf,
              icon: const Icon(EvaIcons.fileText),
              label: const Text("Faturayı Göster"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (log != null) ...[
              CarRepairedLogCard(log: log!),
              const SizedBox(height: 24),
            ],
            buildPartsInputList(),
          ],
        ),
      ),
    );
  }
}
