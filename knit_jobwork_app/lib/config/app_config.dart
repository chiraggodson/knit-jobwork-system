/*import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {

  static bool requireLogin = true;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    requireLogin = prefs.getBool("requireLogin") ?? true;
  }

  static Future<void> setRequireLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("requireLogin", value);
    requireLogin = value;
  }

}*/

/* New Version */
class AppConfig {

  static bool requireLogin = true;

  static Future<void> load() async {
    // temporary config loader
    requireLogin = true;
  }

  static Future<void> setRequireLogin(bool value) async {
    requireLogin = value;
  }

}