import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String value)? onSearchChanged;
  final Function(String value)? onSearchSubmit;

  const SearchField({
    Key? key,
    required this.controller,
    this.onSearchChanged,
    this.onSearchSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: IconButton(
          icon: const Icon(EvaIcons.search),
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (onSearchSubmit != null) onSearchSubmit!(controller.text);
          },
        ),
        hintText: "search..",
        isDense: true,
        fillColor: Theme.of(context).cardColor,
      ),
      onChanged: (value) {
        if (onSearchChanged != null) onSearchChanged!(value);
      },
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        if (onSearchSubmit != null) onSearchSubmit!(controller.text);
      },
      textInputAction: TextInputAction.search,
      style: TextStyle(color: kFontColorPallets[1]),
    );
  }
}
