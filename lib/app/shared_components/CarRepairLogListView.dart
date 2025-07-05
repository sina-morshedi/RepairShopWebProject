import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'CarRepairedLogCard.dart';

class CarRepairLogListView extends StatelessWidget {
  final List<CarRepairLogResponseDTO> logs;

  /// تابعی که برای هر log مشخص می‌کنه آیا دکمه نمایش داده بشه یا نه،
  /// و اگر بشه، متن دکمه و تابع اجراش چیه
  final Map<String, dynamic>? Function(CarRepairLogResponseDTO log)? buttonBuilder;

  const CarRepairLogListView({
    Key? key,
    required this.logs,
    this.buttonBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Text("Hiç kayıt bulunamadı."));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: false,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final buttonData = buttonBuilder?.call(log);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: CarRepairedLogCard(
            log: log,
            extraButtonText: buttonData?['text'] as String?,
            onExtraButtonPressed: buttonData?['onPressed'] as VoidCallback?,
          ),
        );
      },
    );
  }
}
