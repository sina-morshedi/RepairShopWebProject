import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/shared_components/today_text.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';


class Header extends StatelessWidget {
  final Function(String value)? onSearchChanged;
  final Function(String value)? onSearchSubmit;  // اینجا اضافه کن

  const Header({Key? key, this.onSearchChanged, this.onSearchSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Row(
      children: [
        const TodayText(),
        const SizedBox(width: kSpacing),
        Expanded(
          child: TypeAheadField<CarInfoDTO>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Plaka giriniz',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (onSearchSubmit != null) {
                  onSearchSubmit!(value.trim().toUpperCase());
                }
              },
            ),
            suggestionsCallback: (pattern) async {
              if (pattern.trim().isEmpty) return [];
              final response = await CarInfoApi().searchCarsByLicensePlateKeyword(pattern);
              if (response.status == 'success' && response.data != null) {
                return response.data!;
              }
              return [];
            },
            itemBuilder: (context, CarInfoDTO suggestion) {
              return ListTile(
                title: Text(suggestion.licensePlate ?? ''),
                subtitle: suggestion.brandModel != null
                    ? Text(suggestion.brandModel!)
                    : null,
              );
            },
            onSuggestionSelected: (CarInfoDTO suggestion) {
              searchController.text = suggestion.licensePlate ?? '';
              if (onSearchSubmit != null) {
                onSearchSubmit!(suggestion.licensePlate ?? '');
              }
            },
            noItemsFoundBuilder: (context) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Eşleşen araç bulunamadı'),
            ),
          ),
        ),
      ],
    );
  }
}


