import 'package:get/get.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UserProfileDTO.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';


class UserController extends GetxController {
  var user = Rxn<UserProfileDTO>();
  final box = GetStorage();
  UserProfileDTO? get currentUser => user.value;

  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
  }

  void loadUserFromStorage() {
    final storedUserJson = box.read('user');
    if (storedUserJson != null) {
      user.value = UserProfileDTO.fromJson(jsonDecode(storedUserJson));
    }
  }

  void setUser(UserProfileDTO UserProfileDTO) {
    user.value = UserProfileDTO;
    box.write('user', jsonEncode(UserProfileDTO.toJson()));
  }

  void clearUser() {
    user.value = null;
    box.remove('user');
  }
}


