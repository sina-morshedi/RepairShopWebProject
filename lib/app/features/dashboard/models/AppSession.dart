import 'users.dart';


class AppSession {
  /// Holds the currently logged-in user
  static users? currentUser;

  /// Set the current logged-in user
  static void setUser(users user) {
    currentUser = user;
  }

  /// Get the user's role name
  static String? get currentRole => currentUser?.permission.permissionName;

  /// Check if the current user has the given permission
  static bool hasPermission(String permissionName) {
    if (currentUser == null) return false;

    // Grant full access to admin users
    if (currentRole == 'Yönetici') return true;

    // Since each user has only one permission (not a list)
    return currentUser!.permission.permissionName == permissionName;
  }

  /// Clear the current user (e.g. on logout)
  static void clear() {
    currentUser = null;
  }
}
