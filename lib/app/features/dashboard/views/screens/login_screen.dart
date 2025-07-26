import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:repair_shop_web/app/config/routes/app_pages.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/ApiEndpoints.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/backend_services.dart';
import 'dart:convert';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UserProfileDTO.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:jwt_decode/jwt_decode.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  Rxn<UserProfileDTO> user = Rxn<UserProfileDTO>();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();

  bool _rememberMe = false;  // حالت چک‌باکس

  @override
  void initState() {
    super.initState();
    final box = GetStorage();

    // خواندن داده‌های ذخیره شده در صورت وجود
    final savedUsername = box.read('saved_username');
    final savedPassword = box.read('saved_password');
    final savedstoreName = box.read('saved_storeName');
    final savedRememberMe = box.read('saved_rememberMe') ?? false;

    if (savedRememberMe) {
      if (savedUsername != null) _usernameController.text = savedUsername;
      if (savedPassword != null) _passwordController.text = savedPassword;
      if (savedstoreName != null) _storeNameController.text = savedstoreName;
    }

    _rememberMe = savedRememberMe;

    final storedUserJson = box.read('user');
    if (storedUserJson != null) {
      user.value = UserProfileDTO.fromJson(jsonDecode(storedUserJson));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  void setUser(UserProfileDTO newUser) {
    user.value = newUser;
    final box = GetStorage();
    box.write('user', jsonEncode(newUser.toJson()));
  }

  void clearUser() {
    user.value = null;
    final box = GetStorage();
    box.remove('user');
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _storeNameController.dispose();
    super.dispose();
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hata'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Onay'),
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String storeName = _storeNameController.text.trim();

    if (username.isEmpty || password.isEmpty || storeName.isEmpty) {
      Fluttertoast.showToast(msg: "Lütfen tüm alanları doldurun");
      return;
    }

    final String backendUrl =
        '${ApiEndpoints.login}?username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}&storeName=${Uri.encodeComponent(storeName)}';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        if (!mounted) return;

        final data = jsonDecode(response.body);
        final token = data['token'];

        Map<String, dynamic> payload = Jwt.parseJwt(token);
        bool inventoryEnabled = payload['inventoryEnabled'] ?? false;
        bool customerEnabled = payload['customerEnabled'] ?? false;


        // حالا می‌تونی این مقادیر رو ذخیره کنی یا به کنترلرها پاس بدی
        // مثلاً می‌تونی به userController اضافه‌شون کنی
        final userController = Get.find<UserController>();
        userController.setUser(UserProfileDTO.fromJson(data['profile']));
        userController.storeName(storeName);
        userController.inventoryEnabled.value = inventoryEnabled;
        userController.customerEnabled.value = customerEnabled;

        final box = GetStorage();

        box.write('token', token);
        if (_rememberMe) {
          box.write('saved_username', username);
          box.write('saved_password', password);
          box.write('saved_storeName', storeName);
          box.write('saved_rememberMe', true);
        } else {
          // حذف اطلاعات ذخیره شده
          box.remove('saved_username');
          box.remove('saved_password');
          box.remove('saved_storeName');
          box.write('saved_rememberMe', false);
        }

        Get.offNamed(Routes.dashboard);
      } else {
        showErrorDialog(context, response.body);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
      showErrorDialog(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/Welcome.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hoşgeldiniz',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          labelStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(MdiIcons.accountOutline, color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          labelStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(MdiIcons.lockOutline, color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _storeNameController,
                        onSubmitted: (_) => _login(), // ← این خط اضافه شد
                        style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Tamirhane Adı',
                          labelStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(MdiIcons.homeOutline, color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            "Giriş bilgilerini kaydet",
                            style: TextStyle(color: Colors.black87),
                          ),

                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _login,
                          icon: Icon(MdiIcons.login),
                          label: const Text('Login'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
