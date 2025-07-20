import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repair_shop_web/app/features/dashboard/models/InventoryTransactionRequestDTO.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import '../features/dashboard/models/InventoryItemDTO.dart';
import '../features/dashboard/models/InventoryTransactionResponseDTO.dart';
import '../features/dashboard/models/InventoryTransactionRequestDTO.dart';
import '../features/dashboard/models/InventoryTransactionType.dart';
import '../features/dashboard/models/InventoryChangeRequestDTO.dart';
import '../features/dashboard/models/CustomerDTO.dart';  // فرض بر این که مدل مشتری داری
import '../features/dashboard/backend_services/backend_services.dart';
import '../features/dashboard/controllers/UserController.dart';

enum ExitReason { sale, damage }

class InventoryItemExit extends StatefulWidget {
  const InventoryItemExit({Key? key}) : super(key: key);

  @override
  State<InventoryItemExit> createState() => _InventoryItemExitState();
}

class _InventoryItemExitState extends State<InventoryItemExit> {
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

  // سرویس‌ها
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();

    // مشتری‌ها رو با تغییر متن جستجو کن
    _customerSearchController.addListener(() {
      final keyword = _customerSearchController.text.trim();
      if (keyword.length < 2) {
        setState(() => customerSearchResults = []);
        return;
      }
      _searchCustomers(keyword);
    });

    // جستجوی قطعه در صورت تغییر
    _partSearchController.addListener(() {
      final keyword = _partSearchController.text.trim();
      if (keyword.length < 2) {
        setState(() => partSearchResults = []);
        return;
      }
      _searchParts(keyword);
    });
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
        _partSearchController.text = selectedPart!.partName;
      });
    } else {
      setState(() {
        selectedPart = null;
      });
      StringHelper.showErrorDialog(context,'Parça bulunamadı.');
    }
  }

  Future<void> _processExit() async {
    if (_exitReason == null) {
      StringHelper.showErrorDialog(context,'Lütfen çıkış nedenini seçin.');
      return;
    }

    if (_exitReason == ExitReason.sale && selectedCustomer == null) {
      StringHelper.showErrorDialog(context,'Lütfen müşteri seçin.');
      return;
    }

    if (selectedPart == null) {
      StringHelper.showErrorDialog(context,'Lütfen bir parça seçin.');
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      StringHelper.showErrorDialog(context,'Geçerli bir miktar girin.');
      return;
    }

    if ((selectedPart!.quantity ?? 0) < quantity) {
      StringHelper.showErrorDialog(context,'Yeterli stok yok.');
      return;
    }

    // ساخت DTO تراکنش
    final dto = InventoryTransactionRequestDTO(
      carInfoId: null, // اگر نیاز هست اینجا مقدار بده
      customerId: selectedCustomer?.id,
      creatorUserId: userController.currentUser?.userId ?? '',
      inventoryItemId: selectedPart!.id ?? '',
      quantity: quantity,
      type: _exitReason == ExitReason.sale
          ? TransactionType.SALE
          : TransactionType.DAMAGE,
      description: _exitReason == ExitReason.sale
          ? 'Satış çıkışı'
          : 'Hasarlı parça çıkışı',
      dateTime: DateTime.now(),
    );


    final transResponse = await InventoryTransactionApi().addTransaction(dto);
    if (transResponse.status != 'success') {
      StringHelper.showErrorDialog(context, transResponse.message!);
      return;
    }

    final requestDTO = InventoryChangeRequestDTO(
      itemId: selectedPart!.id,
      amount: quantity,
    );

    final response = await InventoryApi().decrementQuantity(requestDTO);

    if (response.status == 'success') {
      StringHelper.showInfoDialog(context,response.message!);
    } else {
      StringHelper.showErrorDialog(context,response.message!);
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


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: _showExitReasonDialog,
            child: const Text('Çıkış Nedeni Seç'),
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
                      _customerSearchController.text = customer.fullName;
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
                  // TODO: اسکنر بارکد اضافه کن (در صورت نیاز)
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
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  final barcode = _barcodeController.text.trim();
                  if (barcode.isNotEmpty) {
                    _searchPartByBarcode(barcode);
                  } else {
                    StringHelper.showErrorDialog(context, 'Lütfen bir barkod girin.');
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('Ara'),
              ),
            ],
          ),

          if (partSearchResults.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                        _partSearchController.text = part.partName ?? '';
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

          ElevatedButton.icon(
            onPressed: _processExit,
            icon: const Icon(Icons.outbox),
            label: const Text('Çıkışı Onayla'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
