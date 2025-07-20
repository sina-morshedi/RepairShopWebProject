import 'package:flutter/material.dart';

class RepairmenLogFilterTab extends StatefulWidget {
  const RepairmenLogFilterTab({super.key});

  @override
  State<RepairmenLogFilterTab> createState() => _RepairmenLogFilterTabState();
}

class _RepairmenLogFilterTabState extends State<RepairmenLogFilterTab> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Filtreleme Paneli (Tamirci)',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
