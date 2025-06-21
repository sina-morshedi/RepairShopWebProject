part of app_helpers;

class StringHelper {
  static void showMessage(String message, {BuildContext? context}) {
    if (kIsWeb && context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      Fluttertoast.showToast(msg: message);
    }
  }
}

