part of 'app_pages.dart';

/// used to switch pages
class Routes {
  static const dashboard = _Paths.dashboard;
  static const insertCarInfo = _Paths.insertCarInfo;
  static const login = _Paths.login;
  static const settings = _Paths.settings;
  static const troubleshooting = _Paths.troubleshooting;
  static const reports = _Paths.reports;
}

/// contains a list of route names.
// made separately to make it easier to manage route naming
class _Paths {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const insertCarInfo = '/insertCarInfo';
  static const settings = '/settings';
  static const troubleshooting = '/troubleshooting';
  static const reports = '/reports';

  // Example :
  // static const index = '/';
  // static const splash = '/splash';
  // static const product = '/product';
}
