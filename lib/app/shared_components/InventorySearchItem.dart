import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'InventoryItemsTable.dart';
import '../features/dashboard/models/InventoryItemDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';

class InventorySearchItem extends StatefulWidget {
  const InventorySearchItem({super.key});

  @override
  State<InventorySearchItem> createState() => _InventorySearchItemState();
}

class _InventorySearchItemState extends State<InventorySearchItem> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _partNameController = TextEditingController();
  List<InventoryItemDTO> searchResults = [];
  String? permissionName;

  bool _showDeleteIcon = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final userController = Get.find<UserController>();
    permissionName =
        userController.currentUser?.permission.permissionName ?? "";

    // Live search listener for part name
    //_partNameController.addListener(_onPartNameChanged);
  }

  void _onPartNameChanged(String value) {
    final partName = value.trim();

    // اگر رشته کمتر از 2 کاراکتر است یا خالی است
    if (partName.isEmpty || partName.length < 2) {
      // تایمر قبلی رو کنسل کن
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      // نتایج جستجو رو خالی کن
      setState(() => searchResults = []);
      return;
    }

    // اگر تایمر قبلی هنوز فعال است لغو کن
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _onSearch('', partName);
    });
  }

  void _submit() {
    final barcode = _barcodeController.text.trim();
    final partName = _partNameController.text.trim();

    if (barcode.isEmpty && partName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir arama kriteri girin.')),
      );
      return;
    }

    _onSearch(barcode, partName);
  }

  void _deleteItem(InventoryItemDTO item) async {
    if (item == null) return;

    final confirmed =
    await StringHelper.showConfirmDialog(context, "Silmek istiyor musunuz?");
    if (!confirmed) return;

    final response = await InventoryApi().deleteItem(item.id);

    if (response.status == 'success') {
      StringHelper.showInfoDialog(context, response.message!);
      // حذف از لیست محلی
      setState(() {
        searchResults.removeWhere((element) => element.id == item.id);
      });
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  void _onSearch(String barcode, String partName) async {
    setState(() => searchResults = []);

    if (barcode.isNotEmpty) {
      final response = await InventoryApi().getItemByBarcode(barcode);
      if (response.status == 'success') {
        setState(() {
          searchResults = [response.data!];
        });
      } else {
        StringHelper.showErrorDialog(context, response.message ?? 'Bir hata oluştu');
      }
    } else if (partName.isNotEmpty) {
      final response = await InventoryApi().getByPartName(partName);
      if (response.status == 'success') {
        setState(() {
          searchResults = response.data ?? [];
        });
      } else {
        //StringHelper.showErrorDialog(context, response.message ?? 'Bir hata oluştu');
      }
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _partNameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                  decoration: InputDecoration(
                    labelText: 'Barkod ile Ara',
                    prefixIcon: Icon(MdiIcons.barcode),
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (value) {
                    _submit();
                  },
                ),
                TextFormField(
                  controller: _partNameController,
                  decoration: const InputDecoration(
                    labelText: 'Parça Adı ile Ara',
                    prefixIcon: Icon(EvaIcons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onPartNameChanged,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (permissionName == "Yönetici")
                      Row(
                        children: [
                          Checkbox(
                            value: _showDeleteIcon,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _showDeleteIcon = value;
                                });
                              }
                            },
                          ),
                          const Text('Silme Modu'),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (searchResults.isNotEmpty)
            InventoryItemsTable(
              items: searchResults,
              showDeleteIcon: _showDeleteIcon,
              onDelete: _deleteItem,
            )
          else
            const Center(child: Text('Arama sonucu yok')),
        ],
      ),
    );
  }
}
