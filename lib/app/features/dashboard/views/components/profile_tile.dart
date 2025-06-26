import 'package:repair_shop_web/app/features/dashboard/views/screens/login_screen.dart';
import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilTile extends StatelessWidget {
  const ProfilTile(
      {required this.data, required this.onPressedNotification, Key? key})
      : super(key: key);

  final Profile data;
  final Function() onPressedNotification;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: CircleAvatar(backgroundImage: data.photo),
      title: Text(
        data.first_name,
        style: TextStyle(fontSize: 14, color: kFontColorPallets[0]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${data.last_name}    ${data.role_name}',
        style: TextStyle(fontSize: 12, color: kFontColorPallets[2]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        onPressed: () {
          // مرحله ۱: پاک کردن اطلاعات ورود
          // مثلاً پاک کردن توکن از حافظه
          // SharedPreferences prefs = await SharedPreferences.getInstance();
          // await prefs.remove("authToken");

          // مرحله ۲: رفتن به صفحه‌ی لاگین یا صفحه‌ی اول
          Get.offAll(() => LoginPage()); // یا LoginPage()، هرچی اسمش هست
        },
        icon: const Icon(FontAwesomeIcons.signOutAlt),
        tooltip: "Çıkış yap",
      ),

    );
  }
}
