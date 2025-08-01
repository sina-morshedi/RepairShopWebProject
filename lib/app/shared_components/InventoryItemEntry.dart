import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import '../features/dashboard/models/InventoryItemDTO.dart';
import '../features/dashboard/models/InventoryChangeRequestDTO.dart';
import '../features/dashboard/models/InventoryTransactionType.dart';
import '../features/dashboard/models/InventoryTransactionRequestDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';

class InventoryItemEntry extends StatefulWidget {
  const InventoryItemEntry({super.key});

  @override
  State<InventoryItemEntry> createState() => _InventoryItemEntryState();
}

class _InventoryItemEntryState extends State<InventoryItemEntry> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _partNameController = TextEditingController();
  final TextEditingController _quantityToAddController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();

  InventoryItemDTO? currentItem;
  String? permissionName;
  List<InventoryItemDTO> searchResults = [];

  @override
  void initState() {
    super.initState();
    final userController = Get.find<UserController>();
    permissionName = userController.currentUser?.permission.permissionName ?? "";

    _partNameController.addListener(_onPartNameChanged);
  }

  void _onPartNameChanged() {
    final input = _partNameController.text.trim().toUpperCase();
    if (input.length < 2) return;
    _searchByPartName(input);
  }

  Future<void> _searchByPartName(String partName) async {
    final response = await InventoryApi().getByPartName(partName);
    if (response.status == 'success') {
      setState(() {
        searchResults = response.data!;
      });
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  Future<void> _searchItem() async {
    final barcode = _barcodeController.text.trim().toUpperCase();
    final partName = _partNameController.text.trim().toUpperCase();

    if (barcode.isEmpty && partName.isEmpty) {
      StringHelper.showErrorDialog(context, "Lütfen barkod veya parça adı girin.");
      return;
    }

    setState(() {
      currentItem = null;
      searchResults.clear();
    });

    if (barcode.isNotEmpty) {
      final response = await InventoryApi().getItemByBarcode(barcode);
      if (response.status == 'success') {
        final item = response.data!;
        setState(() {
          currentItem = item;
          _purchasePriceController.text = item.purchasePrice?.toString() ?? '';
          _salePriceController.text = item.salePrice?.toString() ?? '';
          _quantityToAddController.text = '';
        });
      } else {
        StringHelper.showErrorDialog(context, "Parça bulunamadı.");
      }
    }
  }

  Future<void> _applyUpdate() async {
    if (currentItem == null) return;

    final quantityToAdd = int.tryParse(_quantityToAddController.text.trim()) ?? 0;
    final userController = Get.find<UserController>();

    final request = InventoryChangeRequestDTO(
      itemId: currentItem!.id,
      amount: quantityToAdd,
      updatedAt: DateTime.now(),
      purchasePrice: double.tryParse(_purchasePriceController.text.trim()),
      salePrice: double.tryParse(_salePriceController.text.trim()),
      creatorUserId: userController.currentUser?.userId,
    );

    final response = await InventoryApi().incrementQuantity(request);
    if (response.status == 'success') {
      setState(() {
        currentItem!.quantity = (currentItem!.quantity ?? 0) + quantityToAdd;
        currentItem!.purchasePrice = request.purchasePrice;
        currentItem!.salePrice = request.salePrice;
        currentItem!.updatedAt = request.updatedAt;
        _quantityToAddController.text = '';
      });
    } else {
      StringHelper.showErrorDialog(context, response.message ?? "Hata oluştu.");
      return;
    }

    final dto = InventoryTransactionRequestDTO(
      creatorUserId: userController.currentUser?.userId ?? '',
      inventoryItemId: currentItem!.id ?? '',
      quantity: quantityToAdd,
      type: TransactionType.INCOMING,
      description: 'Depoya ürün kabulü',
      dateTime: DateTime.now(),
    );


    final transResponse = await InventoryTransactionApi().addTransaction(dto);
    if (transResponse.status == 'success')
      StringHelper.showInfoDialog(context, transResponse.message!);
    else
      StringHelper.showErrorDialog(context, transResponse.message!);

  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _partNameController.dispose();
    _quantityToAddController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Wrap(
              runSpacing: 10,
              children: [
                TextFormField(
                  controller: _barcodeController,
                  textInputAction: TextInputAction.search, // برای اینکه دکمه کیبورد بشه "Search"
                  decoration: InputDecoration(
                    labelText: 'Barkod',
                    prefixIcon: Icon(MdiIcons.barcodeScan),
                    border: const OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (value) {
                    _searchItem(); // تابع async رو صدا می‌زنیم، نیازی به await نیست
                  },
                ),
                TextFormField(
                  controller: _partNameController,
                  decoration: InputDecoration(
                    labelText: 'Parça Adı (Canlı Arama)',
                    prefixIcon: Icon(EvaIcons.search),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          if (searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sonuçlar:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Colors.green),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Parça Adı', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Barkod', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      ...searchResults.map((item) {
                        return TableRow(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentItem = item;
                                  _purchasePriceController.text = item.purchasePrice?.toString() ?? '';
                                  _salePriceController.text = item.salePrice?.toString() ?? '';
                                  _quantityToAddController.text = '';
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(item.partName),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentItem = item;
                                  _purchasePriceController.text = item.purchasePrice?.toString() ?? '';
                                  _salePriceController.text = item.salePrice?.toString() ?? '';
                                  _quantityToAddController.text = '';
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(item.barcode),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          if (currentItem != null) ...[
            InventoryItemTable(item: currentItem!),
            const SizedBox(height: 16),

            _buildInput(_quantityToAddController, 'Eklenecek Miktar', isNumber: true),
            const SizedBox(height: 12),

            _buildInput(_purchasePriceController, 'Yeni Alış Fiyatı (₺)', isNumber: true),
            const SizedBox(height: 12),

            _buildInput(_salePriceController, 'Yeni Satış Fiyatı (₺)', isNumber: true),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _applyUpdate,
              icon: Icon(MdiIcons.contentSaveCheck),
              label: const Text('Güncelle'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }
}

class InventoryItemTable extends StatelessWidget {
  final InventoryItemDTO item;

  const InventoryItemTable({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
      children: [
        _buildRow('Parça Adı', item.partName),
        _buildRow('Barkod', item.barcode),
        _buildRow('Kategori', item.category),
        _buildRow('Miktar', '${item.quantity ?? "-"} ${item.unit}'),
        _buildRow('Lokasyon', item.location),
        _buildRow('Alış Fiyatı', '${item.purchasePrice ?? "-"} ₺'),
        _buildRow('Satış Fiyatı', '${item.salePrice ?? "-"} ₺'),
      ],
    );
  }

  TableRow _buildRow(String label, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(label)),
        Padding(padding: const EdgeInsets.all(8), child: Text(value)),
      ],
    );
  }
}
