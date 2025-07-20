import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'RepairmenLogListTab.dart';
import 'RepairmenLogFilterTab.dart';

class RepairmenForm extends StatefulWidget {
  const RepairmenForm({super.key});

  @override
  _RepairmenFormState createState() => _RepairmenFormState();
}

class _RepairmenFormState extends State<RepairmenForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              tabs: [
                Tab(text: "Tüm Onarımlar"),
                Tab(text: "Filtrele"),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 600,
              child: const TabBarView(
                children: [
                  RepairmenLogListTab(),
                  RepairmenLogFilterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
