import 'dart:io';

String platformBaseUrl() {
  if (Platform.isAndroid) return 'http://10.128.5.73:8000';
  return 'http://127.0.0.1:8000';
}
