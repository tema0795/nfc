import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _kHasPin = 'has_pin';

  static Future<bool> getHasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHasPin) ?? false;
  }

  static Future<void> setHasPin(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasPin, v);
  }
}
