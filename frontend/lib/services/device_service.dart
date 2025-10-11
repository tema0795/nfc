import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const _key = 'device_id';

  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_key, id);
    }
    return id;
  }
}
