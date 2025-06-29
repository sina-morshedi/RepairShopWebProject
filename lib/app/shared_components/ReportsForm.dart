
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';

class ReportsForm extends StatefulWidget {
  @override
  _ReportsFormState createState() => _ReportsFormState();
}

class _ReportsFormState extends State<ReportsForm> {

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
              height: 600,  // istediğiniz yükseklik
              child: const TabBarView(
                children: [
                  AllReportsTab(),
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

class AllReportsTab extends StatelessWidget {
  const AllReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // API'den veri alınacak alan
    return const Center(
      child: Text('Tüm raporların listesi', style: TextStyle(fontSize: 18)),
    );
  }
}




