import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';


class TroubleshootingController extends GetxController {



  // Data
  Profile getProfil() {
    final UserController userController = Get.find<UserController>();
    final user = userController.user.value;
    return Profile(
      photo: AssetImage(ImageRasterPath.avatar1),
      first_name: user!.firstName,
      last_name: user!.lastName,
      role_name: user!.role.roleName,
    );
  }


  ProjectCardData getSelectedProject() {
    return ProjectCardData(
      percent: .3,
      projectImage: const AssetImage(ImageRasterPath.logo1),
      projectName: "Nano Electronics Bolu",
      releaseTime: DateTime.now(),
    );
  }
}
