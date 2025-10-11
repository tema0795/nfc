import 'platform_base.dart'
    if (dart.library.io) 'platform_io.dart'
    if (dart.library.html) 'platform_web.dart';

class ApiConfig {
  static String get baseUrl => platformBaseUrl();
}
