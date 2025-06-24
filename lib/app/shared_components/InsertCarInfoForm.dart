import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/ApiEndpoints.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfo.dart';
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
    final ApiResponse<CarInfo> response = await backend_services()
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
                  decoration: const InputDecoration(
                    labelText: "Şasi Numarası",
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
                  decoration: const InputDecoration(
                    labelText: "Motor Numarası",
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
                  decoration: const InputDecoration(
                    labelText: "Plaka Numarası",
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
                  decoration: const InputDecoration(
                    labelText: "Marka",
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
                  decoration: const InputDecoration(
                    labelText: "Model",
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
                  decoration: const InputDecoration(
                    labelText: "Yapım Yılı",
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
                  decoration: const InputDecoration(
                    labelText: "Yakıt Türü",
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
                        debugPrint("Form doğrulandı, kayıt işlemi yapılabilir.");
                      } else {
                        debugPrint("Form doğrulama başarısız.");
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
