import 'package:get/get.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UserProfileDTO.dart';

class UserController extends GetxController {
  var user = Rxn<UserProfile>();

  void setUser(UserProfile userProfile) {
    user.value = userProfile;
  }
}
