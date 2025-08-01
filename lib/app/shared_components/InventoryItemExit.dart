import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repair_shop_web/app/features/dashboard/models/InventoryTransactionRequestDTO.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import '../features/dashboard/models/InventoryItemDTO.dart';
import '../features/dashboard/models/InventoryTransactionResponseDTO.dart';
import '../features/dashboard/models/InventoryTransactionRequestDTO.dart';
import '../features/dashboard/models/InventoryTransactionType.dart';
import '../features/dashboard/models/InventoryChangeRequestDTO.dart';
import '../features/dashboard/models/CustomerDTO.dart';
import '../features/dashboard/backend_services/backend_services.dart';
import '../features/dashboard/controllers/UserController.dart';
import '../features/dashboard/models/InventorySaleLogDTO.dart';
import '../features/dashboard/models/SaleItem.dart';
import '../features/dashboard/backend_services/backend_services.dart';
import 'InventorySelectedPartCard.dart';

enum ExitReason { sale, damage }

class InventoryItemExit extends StatefulWidget {
  const InventoryItemExit({Key? key}) : super(key: key);

  @override
  State<InventoryItemExit> createState() => _InventoryItemExitState();
}

class _InventoryItemExitState extends State<InventoryItemExit> {
  late VoidCallback _customerListener;
  late VoidCallback _partListener;

  ExitReason? _exitReason;

  // کنترلرها
  final TextEditingController _customerSearchController = TextEditingController();
  final TextEditingController _partSearchController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // داده‌ها
  List<CustomerDTO> customerSearchResults = [];
  CustomerDTO? selectedCustomer;

  List<InventoryItemDTO> partSearchResults = [];
  InventoryItemDTO? selectedPart;

  List<InventoryItemDTO> selectedPartsList = [];

  // سرویس‌ها
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();

    _customerListener = () {
      final keyword = _customerSearchController.text.trim();
      if (keyword.length < 2) {
        setState(() => customerSearchResults = []);
        return;
      }
      _searchCustomers(keyword);
    };
    _customerSearchController.addListener(_customerListener);

    _partListener = () {
      final keyword = _partSearchController.text.trim();
      if (keyword.length < 2) {
        setState(() => partSearchResults = []);
        return;
      }
      _searchParts(keyword);
    };
    _partSearchController.addListener(_partListener);
  }

  Future<void> _searchCustomers(String keyword) async {
    final response = await CustomerApi().searchCustomerByName(keyword.toUpperCase());
    if (response.status == 'success') {
      setState(() {
        customerSearchResults = response.data!;
      });
    } else {
      setState(() {
        customerSearchResults = [];
      });
    }
  }

  Future<void> _searchParts(String keyword) async {
    final response = await InventoryApi().getByPartName(keyword.toUpperCase());
    if (response.status == 'success') {
      setState(() {
        partSearchResults = response.data!;
      });
    } else {
      setState(() {
        partSearchResults = [];
      });
    }
  }

  Future<void> _searchPartByBarcode(String barcode) async {
    final response = await InventoryApi().getItemByBarcode(barcode.toUpperCase());
    if (response.status == 'success') {
      setState(() {
        selectedPart = response.data!;
        partSearchResults = [];
        _partSearchController.text = selectedPart!.partName ?? '';
      });
    } else {
      setState(() {
        selectedPart = null;
      });
      StringHelper.showErrorDialog(context, 'Parça bulunamadı.');
    }
  }

  Future<void> _processExit() async {
    if (_exitReason == null) {
      StringHelper.showErrorDialog(context, 'Lütfen çıkış nedenini seçin.');
      return;
    }

    if (_exitReason == ExitReason.sale && selectedCustomer == null) {
      StringHelper.showErrorDialog(context, 'Lütfen müşteri seçin.');
      return;
    }

    if (selectedPart == null) {
      StringHelper.showErrorDialog(context, 'Lütfen bir parça seçin.');
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      StringHelper.showErrorDialog(context, 'Geçerli bir miktar girin.');
      return;
    }

    if ((selectedPart!.quantity ?? 0) < quantity) {
      StringHelper.showErrorDialog(context, 'Yeterli stok yok.');
      return;
    }

    // ساخت تراکنش‌ها برای همه قطعات انتخاب‌شده
    for (InventoryItemDTO item in selectedPartsList) {
      final dto = InventoryTransactionRequestDTO(
        carInfoId: null,
        customerId: selectedCustomer?.id,
        creatorUserId: userController.currentUser?.userId ?? '',
        inventoryItemId: item.id ?? '',
        quantity: item.quantity ?? 0,
        type: _exitReason == ExitReason.sale ? TransactionType.SALE : TransactionType.DAMAGE,
        description: _exitReason == ExitReason.sale ? 'Satış çıkışı' : 'Hasarlı parça çıkışı',
        dateTime: DateTime.now(),
      );

      final transResponse = await InventoryTransactionApi().addTransaction(dto);
      if (transResponse.status != 'success') {
        StringHelper.showErrorDialog(context, transResponse.message!);
        return;
      }

      final requestDTO = InventoryChangeRequestDTO(
        itemId: item.id,
        amount: item.quantity,
      );

      final response = await InventoryApi().decrementQuantity(requestDTO);
      if (response.status != 'success') {
        StringHelper.showErrorDialog(context, response.message!);
        return;
      }
    }

    final saleLogDto = InventorySaleLogDTO(
      customerName: selectedCustomer?.fullName,
      soldItems: selectedPartsList.map((item) {
        return SaleItem(
          inventoryItemId: item.id,
          partName: item.partName,
          quantitySold: item.quantity,
          unitSalePrice: item.purchasePrice,
        );
      }).toList(),
      totalAmount: selectedPartsList.fold<double>(
        0,
            (sum, item) => sum + ((item.quantity ?? 0) * (item.purchasePrice ?? 0)),
      ),
      saleDate: DateTime.now(),
      paymentRecords: [],
    );

    final saleLogResponse = await InventorySaleLogApi().saveSaleLog(saleLogDto);

    if (saleLogResponse.status == 'success') {
      StringHelper.showInfoDialog(context, 'Satış kaydı başarıyla oluşturuldu.');
      setState(() {
        selectedPartsList.clear();
        selectedCustomer = null;
        _quantityController.clear();
        _partSearchController.clear();
        _customerSearchController.clear();
        _barcodeController.clear();
        _exitReason = null;
      });
    } else {
      StringHelper.showErrorDialog(context, saleLogResponse.message ?? 'Satış kaydı oluşturulamadı.');
    }
  }

  Future<void> _showExitReasonDialog() async {
    ExitReason? _tempSelectedReason = _exitReason;

    final result = await showDialog<ExitReason>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Çıkış nedeni seçin'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ExitReason>(
                  title: const Text('Satış'),
                  value: ExitReason.sale,
                  groupValue: _tempSelectedReason,
                  onChanged: (val) {
                    setDialogState(() => _tempSelectedReason = val);
                  },
                ),
                RadioListTile<ExitReason>(
                  title: const Text('Hasarlı Parça'),
                  value: ExitReason.damage,
                  groupValue: _tempSelectedReason,
                  onChanged: (val) {
                    setDialogState(() => _tempSelectedReason = val);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_tempSelectedReason != null) {
                    Navigator.pop(context, _tempSelectedReason);
                  }
                },
                child: const Text('Tamam'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      setState(() {
        _exitReason = result;
      });
    }
  }

  void addSelectedPartToList() {
    if (selectedPart != null) {
      final quantity = int.tryParse(_quantityController.text.trim());
      if (quantity == null || quantity <= 0) {
        StringHelper.showErrorDialog(context, 'Lütfen geçerli bir miktar girin.');
        return;
      }

      setState(() {
        final partCopy = InventoryItemDTO(
          id: selectedPart!.id,
          partName: selectedPart!.partName,
          purchasePrice: selectedPart!.purchasePrice,
          quantity: quantity,
          barcode: selectedPart!.barcode,
        );
        selectedPartsList.add(partCopy);
        StringHelper.showInfoDialog(context, 'Parça listeye eklendi.');
      });
    } else {
      StringHelper.showErrorDialog(context, 'Lütfen önce bir parça seçin.');
    }
  }

  double calculateTotalPrice() {
    return selectedPartsList.fold(0.0, (sum, part) {
      final qty = part.quantity ?? 0;
      final unitPrice = part.purchasePrice ?? 0;
      return sum + (qty * unitPrice);
    });
  }

  bool get _isExitButtonActive {
    if (_exitReason == ExitReason.sale) {
      return selectedPartsList.isNotEmpty;
    }
    if (_exitReason == ExitReason.damage) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: _showExitReasonDialog,
                child: const Text('Çıkış Nedeni Seç'),
              ),
              const SizedBox(width: 8),
              if (_exitReason == ExitReason.sale)
                ElevatedButton.icon(
                  onPressed: addSelectedPartToList,
                  icon: Icon(MdiIcons.plus),
                  label: const Text('Parçayı Listeye Ekle'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_exitReason == ExitReason.sale) ...[
            TextField(
              controller: _customerSearchController,
              decoration: const InputDecoration(
                labelText: 'Müşteri Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            if (customerSearchResults.isNotEmpty)
              ...customerSearchResults.map((customer) {
                return ListTile(
                  title: Text(customer.fullName),
                  subtitle: Text(customer.phone ?? ''),
                  onTap: () {
                    setState(() {
                      selectedCustomer = customer;

                      _customerSearchController.removeListener(_customerListener);
                      _customerSearchController.text = customer.fullName;
                      _customerSearchController.addListener(_customerListener);

                      customerSearchResults.clear();
                    });
                  },
                );
              }).toList(),
            const SizedBox(height: 16),
          ],

          TextField(
            controller: _partSearchController,
            decoration: InputDecoration(
              labelText: 'Parça Adı Ara',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () async {
                  // TODO: اسکنر بارکد اضافه کن در صورت نیاز
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barkod ile Ara',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final barcode = value.trim();
                    if (barcode.isNotEmpty) {
                      _searchPartByBarcode(barcode);
                    } else {
                      StringHelper.showErrorDialog(context, 'Lütfen bir barkod girin.');
                    }
                  },
                ),
              ),
            ],
          ),

          if (partSearchResults.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: partSearchResults.length,
              itemBuilder: (context, index) {
                final part = partSearchResults[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(part.partName ?? 'İsimsiz Parça'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Barkod: ${part.barcode ?? '---'}'),
                        Text('Stok Miktarı: ${part.quantity ?? 0}'),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedPart = part;

                        _partSearchController.removeListener(_partListener);
                        _partSearchController.text = part.partName ?? '';
                        _partSearchController.addListener(_partListener);

                        // اینجا مقدار بارکد رو ست می‌کنیم
                        _barcodeController.text = (part.barcode != null && part.barcode!.isNotEmpty)
                            ? part.barcode!
                            : '-';

                        partSearchResults.clear();
                      });
                    },
                  ),
                );
              },
            ),

          const SizedBox(height: 16),

          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Çıkacak Miktar',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 20),

          if (selectedPartsList.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seçilen Parçalar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...selectedPartsList.map((part) {
                  return InventorySelectedPartCard(
                    part: part,
                    onDelete: () {
                      setState(() {
                        selectedPartsList.remove(part);
                      });
                    },
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            Text(
              'Toplam Fiyat: ${calculateTotalPrice().toStringAsFixed(2)}₺',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _isExitButtonActive ? _processExit : null,
            icon: Icon(MdiIcons.archiveArrowDownOutline),
            label: const Text('Çıkışı Onayla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isExitButtonActive ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    _partSearchController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
