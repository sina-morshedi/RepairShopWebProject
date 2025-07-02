import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:repair_shop_web/app/config/routes/app_pages.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/ApiEndpoints.dart';
import 'dart:convert';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UserProfileDTO.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
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
    super.dispose();
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('خطا'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('تأیید'),
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "لطفا همه فیلدها را پر کنید");
      return;
    }

    final String backendUrl =
        '${ApiEndpoints.login}?username=$username&password=$password';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        if (!mounted) return;

        final data = jsonDecode(response.body);
        UserProfileDTO userProfileDTO = UserProfileDTO.fromJson(data);
        final userController = Get.find<UserController>();
        userController.setUser(userProfileDTO);
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
                        'Welcome',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w600), // متن پررنگ خاکستری
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600), // label پررنگ‌تر
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(EvaIcons.personOutline, color: Colors.blueAccent),
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
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(EvaIcons.lockOutline, color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login),
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
