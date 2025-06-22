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
  static void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(EvaIcons.alertTriangle, color: Colors.red), // Eva error icon
              SizedBox(width: 8),
              Text(
                'Hata:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('TAMAM'),
            ),
          ],
        );
      },
    );
  }

  static void showInfoDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(EvaIcons.info, color: Colors.blue), // Left info icon
              SizedBox(width: 8),
              Text('Bilgi:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.info, color: Colors.blue), // Right info icon
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('TAMAM'),
            ),
          ],
        );
      },
    );
  }


}

