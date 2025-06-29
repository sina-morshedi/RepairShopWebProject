import 'dart:math';

import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/ApiEndpoints.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfo.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';

class ReportsForm extends StatefulWidget {
  @override
  _ReportsFormState createState() => _ReportsFormState();
}

class _ReportsFormState extends State<ReportsForm> {

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

class FilterReportsTab extends StatefulWidget {
  const FilterReportsTab({super.key});

  @override
  State<FilterReportsTab> createState() => _FilterReportsTabState();
}

class _FilterReportsTabState extends State<FilterReportsTab> {
  String? selectedFilter; // برای انتخاب فیلتر: "Plaka" یا "Görev Durumu"
  final TextEditingController _plateController = TextEditingController();
  String? selectedStatus;

  final List<String> filterOptions = [
    'Plaka',
    'Görev Durumu',
  ];

  final List<String> taskStatuses = [
    'Tamamlandı',
    'Beklemede',
    'İptal Edildi',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtre Türü:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedFilter,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            hint: const Text('Filtre türü seçin'),
            items: filterOptions.map((filter) {
              return DropdownMenuItem<String>(
                value: filter,
                child: Text(filter),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedFilter = value;
                // اگر فیلتر تغییر کرد، مقادیر ورودی را پاک کن
                _plateController.clear();
                selectedStatus = null;
              });
            },
          ),
          const SizedBox(height: 16),
          // اگر فیلتر روی پلاک بود، تکست‌فیلد شماره پلاک نمایش داده شود
          if (selectedFilter == 'Plaka') ...[
            const Text('Araç Plakası:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _plateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Örneğin 14ADF788',
              ),
            ),
          ],
          // اگر فیلتر روی وضعیت بود، دراپ‌داون وضعیت نمایش داده شود
          if (selectedFilter == 'Görev Durumu') ...[
            const Text('Görev Durumu:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Durum seçin'),
              items: taskStatuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),
          ],
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                String filterInfo = '';
                if (selectedFilter == 'Plaka') {
                  filterInfo = 'Plaka: ${_plateController.text}';
                } else if (selectedFilter == 'Görev Durumu') {
                  filterInfo = 'Durum: $selectedStatus';
                } else {
                  filterInfo = 'Lütfen filtre türü seçin';
                }
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Filtre Uygulandı'),
                    content: Text(filterInfo),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Filtreyi Uygula'),
            ),
          ),
        ],
      ),
    );
  }
}

