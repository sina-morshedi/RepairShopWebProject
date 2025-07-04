import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodayText extends StatelessWidget {
  const TodayText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bugün", // "Today" به ترکی
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            DateFormat.yMMMEd('tr_TR').format(DateTime.now()), // نمایش تاریخ ترکی
          )
        ],
      ),
    );
  }

}
