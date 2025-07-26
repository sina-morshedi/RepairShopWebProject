import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';

class Header extends StatelessWidget {
  final Function(String value)? onSearchChanged;
  final Function(String value)? onSearchSubmit;  // اینجا اضافه کن

  const Header({Key? key, this.onSearchChanged, this.onSearchSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return Row(
      children: [
        const TodayText(),
        const SizedBox(width: kSpacing),
        Expanded(
          child: SearchField(
            controller: searchController,
            onSearchChanged: onSearchChanged,
            onSearchSubmit: onSearchSubmit,  // پاس بده
          ),
        ),
      ],
    );
  }
}


