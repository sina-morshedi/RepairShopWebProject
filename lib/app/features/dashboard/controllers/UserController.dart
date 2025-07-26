import 'package:get/get.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UserProfileDTO.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class UserController extends GetxController {
  var user = Rxn<UserProfileDTO>();
  var storeName = RxnString();

  // اضافه کردن دو متغیر واکنشی برای inventory و customer
  var inventoryEnabled = false.obs;
  var customerEnabled = false.obs;

  final box = GetStorage();

  UserProfileDTO? get currentUser => user.value;
  String? get currentStoreName => storeName.value;

  bool get isInventoryEnabled => inventoryEnabled.value;
  bool get isCustomerEnabled => customerEnabled.value;

  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
  }

  void loadUserFromStorage() {
    final storedUserJson = box.read('user');
    final storedStoreName = box.read('storeName');
    final storedInventory = box.read('inventoryEnabled');
    final storedCustomer = box.read('customerEnabled');

    if (storedUserJson != null) {
      user.value = UserProfileDTO.fromJson(jsonDecode(storedUserJson));
    }

    if (storedStoreName != null) {
      storeName.value = storedStoreName;
    }

    if (storedInventory != null) {
      inventoryEnabled.value = storedInventory as bool;
    }

    if (storedCustomer != null) {
      customerEnabled.value = storedCustomer as bool;
    }
  }

  void setUser(UserProfileDTO userProfileDTO) {
    user.value = userProfileDTO;
    box.write('user', jsonEncode(userProfileDTO.toJson()));
  }

  void setStoreName(String name) {
    storeName.value = name;
    box.write('storeName', name);
  }

  void setInventoryEnabled(bool enabled) {
    inventoryEnabled.value = enabled;
    box.write('inventoryEnabled', enabled);
  }

  void setCustomerEnabled(bool enabled) {
    customerEnabled.value = enabled;
    box.write('customerEnabled', enabled);
  }

  void clearUser() {
    user.value = null;
    storeName.value = null;
    inventoryEnabled.value = false;
    customerEnabled.value = false;

    box.remove('user');
    box.remove('storeName');
    box.remove('inventoryEnabled');
    box.remove('customerEnabled');
  }
}
