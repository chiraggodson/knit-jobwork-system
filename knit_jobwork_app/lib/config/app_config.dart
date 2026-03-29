import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {

  static bool requireLogin = true;

  // 🔥 DEV MODE FLAG
  static const bool devBypassLogin = true;

  static Future<void> load() async {
    if (devBypassLogin) {
      requireLogin = false;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    requireLogin = prefs.getBool("requireLogin") ?? true;
  }

  static Future<void> setRequireLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("requireLogin", value);
    requireLogin = value;
  }

}