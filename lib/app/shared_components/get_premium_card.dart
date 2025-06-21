import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';

class GetPremiumCard extends StatelessWidget {
  const GetPremiumCard({
    required this.onPressed,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  final Color? backgroundColor;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(kBorderRadius),
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(kBorderRadius),
        onTap: () {
          debugPrint('Card tapped');
          showDialog(
            context: context,
            builder: (context) => const PremiumAccountDialog(),
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          constraints: const BoxConstraints(
            minWidth: 250,
            maxWidth: 350,
            minHeight: 200,
            maxHeight: 200,
          ),
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: SvgPicture.asset(
                  ImageVectorPath.wavyAddUser,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(15),
                child: _Info(),
              ),
            ],
          ),
        ),
      ),
    );

  }
}

class _Info extends StatelessWidget {
  const _Info({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Premium\nHesap Alın",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Daha fazla üye eklemek için",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}


class PremiumAccountDialog extends StatefulWidget {
  const PremiumAccountDialog({Key? key}) : super(key: key);

  @override
  State<PremiumAccountDialog> createState() => _PremiumAccountDialogState();
}

class _PremiumAccountDialogState extends State<PremiumAccountDialog> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedRole;
  String? _selectedPermission;

  final List<String> _roles = ['Yönetici', 'Teknisyen', 'Müşteri'];
  final List<String> _permissions = ['Tam erişim', 'Sınırlı erişim', 'Görüntüleme'];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // اضافه‌شده برای جلوگیری از خطای overflow در صفحه‌های کوچک
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Yeni Personel Bilgileri",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen kullanıcı adını girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifreyi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Soyadı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen soyadı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Role ComboBox
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: _roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Rol Seçin',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Lütfen bir rol seçin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Permission ComboBox
                DropdownButtonFormField<String>(
                  value: _selectedPermission,
                  items: _permissions.map((perm) {
                    return DropdownMenuItem<String>(
                      value: perm,
                      child: Text(perm),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Yetki Seviyesi',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedPermission = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Lütfen yetki seviyesi seçin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final username = _usernameController.text;
                          final password = _passwordController.text;
                          final firstName = _firstNameController.text;
                          final lastName = _lastNameController.text;

                          print('Kullanıcı: $username');
                          print('Şifre: $password');
                          print('Adı: $firstName');
                          print('Soyadı: $lastName');
                          print('Rol: $_selectedRole');
                          print('Yetki: $_selectedPermission');

                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Onayla'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

