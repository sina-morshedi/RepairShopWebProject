import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'InventoryAddItem.dart';
import 'InventorySearchItem.dart';
import 'InventoryItemsTable.dart';
import 'InventoryManageItems.dart';
import 'InventoryTransactionTable.dart';

class Inventoryform extends StatefulWidget {
  const Inventoryform({super.key});

  @override
  _InventoryformState createState() => _InventoryformState();
}

class _InventoryformState extends State<Inventoryform> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              tabs: [
                Tab(text: "Stoka Parça Ekle"),
                Tab(text: "Yedek Parça İşlemler"),
                Tab(text: "Depo Hareketleri"),
              ],
            ),
            const SizedBox(height: 8),
            // اینجا باید Expanded باشه تا TabBarView به فضای باقی‌مانده برسد
            Expanded(
              child: TabBarView(
                children: [
                  InventoryAddItem(),
                  InventoryManageItems(),
                  InventoryTransactionsTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

