import 'package:flutter/material.dart';
import '../features/dashboard/models/InventorySaleLogDTO.dart';
import '../features/dashboard/models/PaymentRecord.dart';
import '../features/dashboard/models/InventoryChangeRequestDTO.dart';
import '../features/dashboard/models/InventoryTransactionRequestDTO.dart';
import '../features/dashboard/models/UserProfileDTO.dart';
import '../features/dashboard/models/InventoryTransactionType.dart';
import '../features/dashboard/models/SaleItem.dart';
import '../features/dashboard/backend_services/backend_services.dart';
import '../features/dashboard/controllers/UserController.dart';
import '../utils/helpers/app_helpers.dart';
import 'package:get/get.dart';

class InventorySaleLogDetailCard extends StatefulWidget {
  final InventorySaleLogDTO log;
  final String customerId;

  const InventorySaleLogDetailCard({
    required this.log,
    required this.customerId, // 👈 اضافه شده
    Key? key,
  }) : super(key: key);


  @override
  State<InventorySaleLogDetailCard> createState() => _InventorySaleLogDetailCardState();
}

class _InventorySaleLogDetailCardState extends State<InventorySaleLogDetailCard> {
  late InventorySaleLogDTO currentLog;
  bool _isExpanded = false;
  final TextEditingController _paymentController = TextEditingController();
  final Map<String, TextEditingController> _quantityControllers = {};
  final UserController userController = Get.find<UserController>();
  UserProfileDTO? user;

  bool _isSavingPayment = false;

  @override
  void initState() {
    super.initState();
    currentLog = widget.log;
    user = userController.user.value!;
    for (var item in currentLog.soldItems ?? []) {
      _quantityControllers[item.inventoryItemId!] = TextEditingController(text: item.quantitySold?.toString() ?? '0');
    }
  }

  @override
  void dispose() {
    _paymentController.dispose();
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get totalPrice {
    return currentLog.soldItems?.fold<double>(
      0.0,
          (double sum, item) => sum + ((item.quantitySold ?? 0) * (item.unitSalePrice ?? 0)),
    ) ??
        0.0;
  }

  double get totalPaid {
    return currentLog.paymentRecords?.fold<double>(0.0, (sum, record) => sum + (record.amountPaid ?? 0)) ?? 0.0;
  }

  double get remainingAmount {
    return totalPrice - totalPaid;
  }

  Future<void> _savePayment() async {
    final text = _paymentController.text.trim();
    final paymentAmount = double.tryParse(text);

    if (paymentAmount == null || paymentAmount < 0) {
      StringHelper.showErrorDialog(context, 'Lütfen geçerli bir ödeme tutarı girin.');
      return;
    }

    setState(() {
      _isSavingPayment = true;
    });

    try {
      final newPaymentRecord = PaymentRecord(
        amountPaid: paymentAmount,
        paymentDate: DateTime.now(),
      );

      final updatedPaymentRecords = [...?currentLog.paymentRecords, newPaymentRecord];

      final totalPaid = updatedPaymentRecords.fold<double>(
        0,
            (sum, record) => sum + (record.amountPaid ?? 0),
      );

      final remaining = (currentLog.totalAmount ?? 0) - totalPaid;

      final updatedLog = currentLog.copyWith(
        paymentRecords: updatedPaymentRecords,
        remainingAmount: remaining,
      );

      final response = await InventorySaleLogApi().updateSaleLog(currentLog.id!, updatedLog);

      if (response.status == 'success') {
        StringHelper.showInfoDialog(context, 'Ödeme kaydedildi.');
        setState(() {
          currentLog = response.data!;
          _paymentController.clear();
        });
      } else {
        StringHelper.showErrorDialog(context, response.message ?? 'Bir hata oluştu.');
      }
    } catch (e) {
      StringHelper.showErrorDialog(context, 'Ödeme kaydedilirken hata oluştu.');
    } finally {
      setState(() {
        _isSavingPayment = false;
      });
    }
  }

  Future<void> _handleReturnPart() async {
    if (currentLog.soldItems == null || currentLog.soldItems!.isEmpty) {
      StringHelper.showErrorDialog(context, 'Satılan parça bilgisi bulunamadı.');
      return;
    }

    setState(() {
      _isSavingPayment = true;
    });

    try {
      for (final item in currentLog.soldItems!) {
        final incrementDto = InventoryChangeRequestDTO(
          itemId: item.inventoryItemId!,
          amount: item.quantitySold ?? 0,
          updatedAt: DateTime.now(),
        );

        final incrementResponse = await InventoryApi().incrementQuantity(incrementDto);
        if (incrementResponse.status != 'success') {
          StringHelper.showErrorDialog(context, 'Stok artırılamadı: ${incrementResponse.message}');
          return;
        }

        final returnTransaction = InventoryTransactionRequestDTO(
          creatorUserId: user!.userId,
          customerId: widget.customerId,
          inventoryItemId: item.inventoryItemId!,
          quantity: item.quantitySold ?? 0,
          type: TransactionType.RETURN_SALE,
          description: 'Parça iadesi',
          dateTime: DateTime.now(),
        );

        final transactionResponse = await InventoryTransactionApi().addTransaction(returnTransaction);
        if (transactionResponse.status != 'success') {
          StringHelper.showErrorDialog(context, transactionResponse.message!);
          return;
        }
      }

      final deleteResponse = await InventorySaleLogApi().deleteSaleLog(currentLog.id!);
      if (deleteResponse.status != 'success') {
        StringHelper.showErrorDialog(context, deleteResponse.message!);
        return;
      }

      StringHelper.showInfoDialog(context, 'Parça iadesi başarıyla tamamlandı.');
    } catch (e) {
      StringHelper.showErrorDialog(context, 'İade işlemi sırasında hata oluştu: $e');
    } finally {
      setState(() {
        _isSavingPayment = false;
      });
    }
  }

  Future<void> _handleUpdateQuantities() async {
    setState(() {
      _isSavingPayment = true;
    });

    print('currentLog.id: ${currentLog.id}');
    try {
      List<SaleItem> updatedItems = [];

      for (final item in currentLog.soldItems ?? []) {
        final controller = _quantityControllers[item.inventoryItemId!]!;
        final newQty = int.tryParse(controller.text.trim()) ?? 0;
        final oldQty = item.quantitySold ?? 0;
        final diff = newQty - oldQty;

        if (diff == 0) {
          updatedItems.add(item);
          continue;
        }

        final int diffInt = diff.toInt();

        // 1. انبار را آپدیت کن
        final changeDto = InventoryChangeRequestDTO(
          itemId: item.inventoryItemId!,
          amount: diffInt.abs(),
          updatedAt: DateTime.now(),
        );

        final changeResponse = diff > 0
            ? await InventoryApi().decrementQuantity(changeDto)
            : await InventoryApi().incrementQuantity(changeDto);

        print('diffInt');
        print(diffInt);
        if (changeResponse.status != 'success') {
          StringHelper.showErrorDialog(context, changeResponse.message!);
          return;
        }

        // 2. ثبت ترنزکشن
        final transactionDto = InventoryTransactionRequestDTO(
          creatorUserId: user!.userId,
          customerId: widget.customerId,
          inventoryItemId: item.inventoryItemId!,
          quantity: diffInt.abs(),
          type: diff > 0 ? TransactionType.SALE : TransactionType.RETURN_SALE,
          description: 'Satış güncellemesi',
          dateTime: DateTime.now(),
        );

        final transactionResponse = await InventoryTransactionApi().addTransaction(transactionDto);
        if (transactionResponse.status != 'success') {
          StringHelper.showErrorDialog(context, transactionResponse.message!);
          return;
        }

        // 3. مقدار جدید را جایگزین کن
        updatedItems.add(item.copyWith(quantitySold: newQty));
      }


      // 4. آبدیت کردن SaleLog
      final updatedLog = currentLog.copyWith(soldItems: updatedItems);


      final updateLogResponse = await InventorySaleLogApi().updateSaleLog(currentLog.id!, updatedLog);

      if (updateLogResponse.status == 'success') {
        setState(() {
          currentLog = updateLogResponse.data!;
        });
        StringHelper.showInfoDialog(context, 'Miktarlar güncellendi.');
      } else {
        StringHelper.showErrorDialog(context, updateLogResponse.message ?? 'Satış güncellenemedi.');
      }
    } catch (e) {
      StringHelper.showErrorDialog(context, 'Hata oluştu: $e');
    } finally {
      setState(() {
        _isSavingPayment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          ListTile(
            title: Text('Satış Tarihi: ${currentLog.saleDate?.toLocal().toString().split(' ')[0] ?? '-'}'),
            subtitle: Text('Müşteri: ${currentLog.customerName ?? '-'}'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Satılan Parçalar:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // عنوان ستون‌ها
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: const [
                        Expanded(flex: 4, child: Text('Parça Adı', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Adet', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Birim Fiyat', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Toplam', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  ...?currentLog.soldItems?.map((item) {
                    final totalItemPrice = (item.quantitySold ?? 0) * (item.unitSalePrice ?? 0);
                    final controller = _quantityControllers[item.inventoryItemId!]!;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(flex: 4, child: Text(item.partName ?? '-')),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              width: 60,
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          Expanded(flex: 2, child: Text('${item.unitSalePrice?.toStringAsFixed(2) ?? '0.00'} ₺')),
                          Expanded(flex: 2, child: Text('${totalItemPrice.toStringAsFixed(2)} ₺')),
                        ],
                      ),
                    );
                  }).toList(),

                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Toplam: ${totalPrice.toStringAsFixed(2)} ₺', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Ödemeler:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  ...?currentLog.paymentRecords?.map((payment) {
                    final paymentDateStr = payment.paymentDate?.toLocal().toString().split(' ')[0] ?? '-';
                    final paymentAmountStr = (payment.amountPaid ?? 0).toStringAsFixed(2);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(paymentDateStr),
                          Text('$paymentAmountStr ₺'),
                        ],
                      ),
                    );
                  }).toList(),

                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Kalan Tutar: ${remainingAmount.toStringAsFixed(2)} ₺',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: remainingAmount > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _paymentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Ödenen Tutar',
                      border: OutlineInputBorder(),
                      prefixText: '₺ ',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSavingPayment ? null : _savePayment,
                          child: _isSavingPayment
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Ödemeyi Kaydet'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSavingPayment ? null : _handleReturnPart,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: const Text('Parçayı İade Et'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSavingPayment ? null : _handleUpdateQuantities,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                          child: const Text('Parça Miktarını Güncelle'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

}
