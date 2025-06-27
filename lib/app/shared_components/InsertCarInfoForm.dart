import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/ApiEndpoints.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfo.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/utils/helpers/app_helpers.dart';

enum CarFormMode { newCar, searchByPlate }

class InsertCarInfoForm extends StatefulWidget {
  const InsertCarInfoForm({Key? key}) : super(key: key);

  @override
  _InsertCarInfoFormState createState() => _InsertCarInfoFormState();
}

class _InsertCarInfoFormState extends State<InsertCarInfoForm> {
  final _formKey = GlobalKey<FormState>();

  CarFormMode _mode = CarFormMode.newCar;

  final TextEditingController chassisController = TextEditingController();
  final TextEditingController motorController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();

  final TextEditingController searchPlateController = TextEditingController();

  bool _carDataLoaded = false;

  final List<String> tag_labelText = [
    "ŞASE NO",
    "MOTOR NO",
    "PLAKA",
    "MARKASI",
    "TİCARİ ADI",
    "MODEL YILI",
    "YAKIT CİNSİ",
  ];

  @override
  void dispose() {
    chassisController.dispose();
    motorController.dispose();
    plateController.dispose();
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    fuelTypeController.dispose();
    searchPlateController.dispose();
    super.dispose();
  }

  void loadCarInfoByPlate(String plate) async{
    final ApiResponse<CarInfoDTO> response = await backend_services()
        .getCarInfoByLicensePlate(searchPlateController.text.trim().toUpperCase());
    if (response.status == 'successful' && response.data != null) {
      final car = response.data!;

      setState(() {
        plateController.text = car.licensePlate;
        chassisController.text = car.chassisNo;
        motorController.text = car.motorNo;
        brandController.text = car.brand;
        modelController.text = car.brandModel;
        yearController.text = car.modelYear?.toString() ?? '';
        fuelTypeController.text = car.fuelType;
        plateController.text = car.licensePlate;
        _carDataLoaded = true;
      });
    } else {
      StringHelper.showErrorDialog(
        context,
        response.message ?? 'Araç bulunamadı veya sunucu hatası',
      );
    }
  }

  bool get _isFormEnabled {
    if (_mode == CarFormMode.newCar) return true;
    if (_mode == CarFormMode.searchByPlate && _carDataLoaded)return true;
    return false;
  }

  bool validateString(String tag, String str) {
    if (str.isEmpty) {
      StringHelper.showErrorDialog(context, "$tag'nin kutusu boş");
      return false;
    }
    if (str.contains('  ')) {
      StringHelper.showErrorDialog(context, "$tag: boşluk kullanma");
      return false;
    }

    if (RegExp(r'[a-z]').hasMatch(str)) {
      StringHelper.showErrorDialog(context, "$tag: küçük harf kullanma");
      return false;
    }

    return true;
  }

  bool validateNumber(String tag, String str) {
    if (str.isEmpty) {
      StringHelper.showErrorDialog(context, "$tag'nin kutusu boş");
      return false;
    }
    if (str.contains('  ')) {
      StringHelper.showErrorDialog(context, "$tag: boşluk kullanma");
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(str)) {
      StringHelper.showErrorDialog(context, "$tag: Sadece numarayı yazın.");
      return false;
    }

    return true;
  }

  Future<void> saveEditCarInfo() async {
    if (validateString(tag_labelText[0], chassisController.text) == false)
      return;
    if (validateString(tag_labelText[1], motorController.text) == false)
      return;
    if (validateString(tag_labelText[2], plateController.text) ==
        false)
      return;
    if (validateString(tag_labelText[3], brandController.text) == false) return;
    if (validateString(tag_labelText[4], modelController.text) == false) return;
    if (validateString(tag_labelText[6], fuelTypeController.text) == false)
      return;
    if (validateNumber(tag_labelText[5], yearController.text) == false) return;

    final carInfo = CarInfo(
      chassisNo: chassisController.text.toUpperCase(),
      motorNo: motorController.text.toUpperCase(),
      licensePlate: plateController.text.toUpperCase(),
      brand: brandController.text.trim(),
      brandModel: modelController.text.toUpperCase(),
      modelYear: int.tryParse(yearController.text),
      fuelType: fuelTypeController.text.toUpperCase(),
      dateTime: DateTime.now().toIso8601String(),
    );

    if (_mode != CarFormMode.newCar){
      final updatedCar = CarInfo(
        chassisNo: chassisController.text.trim(),
        motorNo: motorController.text.trim(),
        licensePlate: plateController.text.trim(),
        brand: brandController.text.trim(),
        brandModel: modelController.text.trim(),
        modelYear: int.tryParse(yearController.text.trim()),
        fuelType: fuelTypeController.text,
        dateTime: DateTime.now().toIso8601String(),
      );

      final ApiResponse response = await backend_services()
          .updateCarInfoByLicensePlate(
        plateController.text.trim(),
        updatedCar,
      );
      if (response.status != 'error') {
        StringHelper.showInfoDialog(context, 'Düzenleme yapıldı');
      } else {
        StringHelper.showErrorDialog(context, '${response.message}');
      }
    } else {
      final ApiResponse response = await backend_services().insertCarInfo(
        carInfo,
      );
      if (response.status != 'error') {
        StringHelper.showInfoDialog(context, 'başarılı');
      } else {
        StringHelper.showErrorDialog(context, '${response.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Araç Bilgileri", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Radio Buttons
          Row(
            children: [
              Expanded(
                child: RadioListTile<CarFormMode>(
                  title: const Text("Yeni Araç Bilgisi Gir"),
                  value: CarFormMode.newCar,
                  groupValue: _mode,
                  onChanged: (value) {
                    setState(() {
                      _mode = value!;
                      _carDataLoaded = false;
                      _formKey.currentState?.reset();
                      chassisController.clear();
                      motorController.clear();
                      plateController.clear();
                      brandController.clear();
                      modelController.clear();
                      yearController.clear();
                      fuelTypeController.clear();
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<CarFormMode>(
                  title: const Text("Plaka ile Araç Getir"),
                  value: CarFormMode.searchByPlate,
                  groupValue: _mode,
                  onChanged: (value) {
                    setState(() {
                      _mode = value!;
                      _carDataLoaded = false;
                      _formKey.currentState?.reset();
                      chassisController.clear();
                      motorController.clear();
                      plateController.clear();
                      brandController.clear();
                      modelController.clear();
                      yearController.clear();
                      fuelTypeController.clear();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_mode == CarFormMode.searchByPlate)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextFormField(
                controller: searchPlateController,
                decoration: InputDecoration(
                  labelText: "Plaka Numarası Girin",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(EvaIcons.searchOutline),
                    onPressed: () {
                      final plate = searchPlateController.text.trim();
                      if (plate.isEmpty) {
                        Get.snackbar("Hata", "Lütfen plaka numarası girin");
                        return;
                      }
                      loadCarInfoByPlate(plate);
                    },
                  ),
                ),
              ),
            ),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: chassisController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[0],
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  enabled: _isFormEnabled,
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: motorController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[1],
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  enabled: _isFormEnabled,
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: plateController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[2],
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  enabled: _isFormEnabled,
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: brandController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[3],
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  enabled: _isFormEnabled,
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: modelController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[4],
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  enabled: _isFormEnabled,
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: yearController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[5],
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: _isFormEnabled,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Zorunlu alan';
                    if (int.tryParse(value) == null) return 'Geçerli bir sayı giriniz';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: fuelTypeController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[6],
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  enabled: _isFormEnabled,
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(EvaIcons.saveOutline),
                    label: const Text("Kaydet"),
                    onPressed: _isFormEnabled
                        ? () {
                      if (_formKey.currentState?.validate() ?? false) {
                        saveEditCarInfo();
                      } else {
                        print("Form doğrulama başarısız.");
                      }
                    }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
