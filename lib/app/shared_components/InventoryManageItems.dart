import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repair_shop_web/app/shared_components/InventorySearchItem.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'InventoryItemsTable.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

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
                DropdownMenuItem(value: 'arçalar', child: Text("Parçalar")),
                DropdownMenuItem(value: 'giris', child: Text("Giriş Ürünleri")),
                DropdownMenuItem(value: 'cikis', child: Text("Çıkış Ürünleri")),
                DropdownMenuItem(value: 'arama', child: Text("Ürün Arama")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // Content below dropdown
          if (selectedOption == 'arçalar') ...[
            const Text("Giriş Ürünleri gösterilecek"),
            const SizedBox(height: 24),
            InventoryItemsTable(),
          ] else if (selectedOption == 'giris') ...[
            const Text("Giriş Ürünleri gösterilecek"),
            const SizedBox(height: 24),
            InventoryItemEntry(),
          ] else if (selectedOption == 'cikis') ...[
            const Text("Çıkış Ürünleri gösterilecek"),
            const SizedBox(height: 24),
            InventoryItemExit(),
          ] else if (selectedOption == 'arama') ...[
            const Text("Ürün Arama ekranı"),
            const SizedBox(height: 24),
            InventorySearchItem(),
          ],
        ],
      ),
    );
  }
}
