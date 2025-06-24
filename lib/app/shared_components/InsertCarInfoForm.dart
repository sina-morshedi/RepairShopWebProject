import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';

class InsertCarInfoForm extends StatefulWidget {
  const InsertCarInfoForm({Key? key}) : super(key: key);

  @override
  _InsertCarInfoFormState createState() => _InsertCarInfoFormState();
}

class _InsertCarInfoFormState extends State<InsertCarInfoForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController chassisController = TextEditingController();
  final TextEditingController motorController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();

  @override
  void dispose() {
    chassisController.dispose();
    motorController.dispose();
    plateController.dispose();
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    fuelTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Araç Bilgileri", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            TextFormField(
              controller: chassisController,
              decoration: const InputDecoration(
                labelText: "Şasi Numarası",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
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
              validator: (value) => value == null || value.isEmpty ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(EvaIcons.saveOutline),
                label: const Text("Kaydet"),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // TODO: Save action here
                    debugPrint("Form doğrulandı, kayıt işlemi yapılabilir.");
                  } else {
                    debugPrint("Form doğrulama başarısız.");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
