
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/shared_components/FinalReportForEachCarsTab.dart';
import 'package:repair_shop_web/app/shared_components/FilterReportsTab.dart';

class ReportsForm extends StatefulWidget {
  @override
  _ReportsFormState createState() => _ReportsFormState();
}

class _ReportsFormState extends State<ReportsForm>{

  String? str;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // aynı dış boşluk
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              tabs: [
                Tab(text: 'Tüm Raporlar'),
                Tab(text: 'Plakaya Göre Filtre'),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 500,  // istediğiniz yükseklik
              child: const TabBarView(
                children: [
                  FinalReportForEachCarTab(),
                  FilterReportsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





