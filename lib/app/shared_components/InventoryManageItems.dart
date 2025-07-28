import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repair_shop_web/app/shared_components/InventorySearchItem.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'InventoryItemsTable.dart';
import 'InventorySaleLogsForm.dart';
import '../features/dashboard/models/InventoryItemDTO.dart';

import 'InventoryItemEntry.dart';
import 'InventoryItemExit.dart';

class InventoryManageItems extends StatefulWidget {
  const InventoryManageItems({super.key});

  @override
  State<InventoryManageItems> createState() => _InventoryManageItemsState();
}

class _InventoryManageItemsState extends State<InventoryManageItems> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: InputBorder.none),
              value: selectedOption,
              hint: const Text("Bir işlem seçin"),
              items: const [
                DropdownMenuItem(value: 'parçalar', child: Text("Parçalar")),
                DropdownMenuItem(value: 'giris', child: Text("Giriş Ürünleri")),
                DropdownMenuItem(value: 'cikis', child: Text("Çıkış Ürünleri")),
                DropdownMenuItem(value: 'arama', child: Text("Ürün Arama")),
                DropdownMenuItem(value: 'satilan', child: Text("Satılan Parçalar")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // اینجا به جای Expanded از SizedBox با ارتفاع ثابت استفاده می‌کنیم
          SizedBox(
            height: 600, // ارتفاع دلخواه؛ می‌توانید تغییر دهید
            child: Builder(
              builder: (context) {
                if (selectedOption == 'parçalar') {
                  return InventoryItemsTable();
                } else if (selectedOption == 'giris') {
                  return InventoryItemEntry();
                } else if (selectedOption == 'cikis') {
                  return InventoryItemExit();
                } else if (selectedOption == 'arama') {
                  return InventorySearchItem();
                } else if (selectedOption == 'satilan') {
                  return InventorySaleLogsForm();
                } else {
                  return const Center(
                    child: Text("Lütfen bir işlem seçin"),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
