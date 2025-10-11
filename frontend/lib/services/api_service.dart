import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../services/session_storage.dart';

import '../services/device_service.dart';

class ApiService {
  static final String _baseUrl = ApiConfig.baseUrl;

  // ====================== AUTH ======================

  Future<bool> login(String email, String password) async {
    // основной (JWT SimpleJWT)
    final urlPrimary = Uri.parse('$_baseUrl/api/auth/token/');
    final resPrimary = await http.post(
      urlPrimary,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    http.Response res = resPrimary;

    // fallback на твой старый путь
    if (res.statusCode == 404 || res.statusCode == 405) {
      final urlFallback = Uri.parse('$_baseUrl/api/auth/login/');
      res = await http.post(
        urlFallback,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
    }

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final access = data['access'] as String?;
      final refresh = data['refresh'] as String?;
      if (access != null && refresh != null) {
        await _saveTokens(access: access, refresh: refresh);
        return true;
      }
    }
    return false;
  }

  Future<bool> refresh() async {
    final refresh = await _getRefreshToken();
    if (refresh == null) return false;

    // основной (JWT SimpleJWT)
    final urlPrimary = Uri.parse('$_baseUrl/api/auth/token/refresh/');
    final resPrimary = await http.post(
      urlPrimary,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    http.Response res = resPrimary;

    // fallback на твой старый путь
    if (res.statusCode == 404 || res.statusCode == 405) {
      final urlFallback = Uri.parse('$_baseUrl/api/auth/refresh/');
      res = await http.post(
        urlFallback,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );
    }

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final access = data['access'] as String?;
      if (access != null) {
        await _saveTokens(access: access, refresh: refresh);
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // ====================== PIN ======================
  Future<bool> setPin(String pin, {String? deviceId}) async {
    final access = await _getAccessToken();
    if (access == null) return false;

    deviceId ??= await DeviceService.getOrCreateDeviceId();

    final url = Uri.parse('$_baseUrl/api/auth/pin/set/');
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $access',
      },
      body: jsonEncode({'pin': pin, 'device_id': deviceId}),
    );

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (ok) {
      // запомним локально, что устройство использует PIN
      await SessionStorage.setHasPin(true);
    }
    return ok;
  }

  Future<bool> verifyPin(String deviceId, String pin) async {
    final url = Uri.parse('$_baseUrl/api/auth/pin/verify/');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'device_id': deviceId, 'pin': pin}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final newAccess = data['access'] as String?;
      final newRefresh = data['refresh'] as String?;
      if (newAccess != null) {
        // если refresh не прислали — возьмём старый
        final oldRefresh = await _getRefreshToken();
        await _saveTokens(access: newAccess, refresh: newRefresh ?? oldRefresh);
        return true;
      }
    }
    return false;
  }

  Future<void> _saveTokens({required String access, String? refresh}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    if (refresh != null) {
      await prefs.setString('refresh_token', refresh);
    }
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Map<String, String> _jsonHeaders({
    String? access,
    Map<String, String>? extra,
  }) {
    final base = <String, String>{'Content-Type': 'application/json'};
    if (access != null) base['Authorization'] = 'Bearer $access';
    if (extra != null) base.addAll(extra);
    return base;
  }

  /// GET с авто-рефрешем на 401 и одним повтором
  Future<http.Response?> _authedGet(
    String path, {
    Map<String, String>? extraHeaders,
  }) async {
    final access = await _getAccessToken();
    if (access == null) return null;

    var res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _jsonHeaders(access: access, extra: extraHeaders),
    );

    if (res.statusCode == 401) {
      final ok = await refresh();
      if (!ok) return res;
      final access2 = await _getAccessToken();
      if (access2 == null) return res;
      res = await http.get(
        Uri.parse('$_baseUrl$path'),
        headers: _jsonHeaders(access: access2, extra: extraHeaders),
      );
    }
    return res;
  }

  /// POST с авто-рефрешем на 401 и одним повтором
  Future<http.Response?> _authedPost(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
  }) async {
    final access = await _getAccessToken();
    if (access == null) return null;

    final uri = Uri.parse('$_baseUrl$path');

    var res = await http.post(
      uri,
      headers: _jsonHeaders(access: access, extra: extraHeaders),
      body: jsonEncode(body),
    );

    if (res.statusCode == 401) {
      final ok = await refresh();
      if (!ok) return res;
      final access2 = await _getAccessToken();
      if (access2 == null) return res;
      res = await http.post(
        uri,
        headers: _jsonHeaders(access: access2, extra: extraHeaders),
        body: jsonEncode(body),
      );
    }

    return res;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final access = await _getAccessToken();
    if (access == null) return null;

    final uri = Uri.parse('$_baseUrl/api/auth/profile/');
    var res = await http.get(uri, headers: {'Authorization': 'Bearer $access'});

    if (res.statusCode == 401) {
      final ok = await refresh();
      if (!ok) return null;
      final access2 = await _getAccessToken();
      if (access2 == null) return null;
      res = await http.get(uri, headers: {'Authorization': 'Bearer $access2'});
    }

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getNfcToken(String deviceId) async {
    final access = await _getAccessToken();
    if (access == null) return null;

    final url = Uri.parse('$_baseUrl/api/auth/nfc-token/?device_id=$deviceId');
    var res = await http.get(url, headers: {'Authorization': 'Bearer $access'});

    if (res.statusCode == 401) {
      final ok = await refresh();
      if (!ok) return null;
      final access2 = await _getAccessToken();
      if (access2 == null) return null;
      res = await http.get(url, headers: {'Authorization': 'Bearer $access2'});
    }

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> verifyNfc({
    required String deviceId,
    required String token,
    required String tagUid,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/nfc-verify/');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        'token': token,
        'tag_uid': tagUid,
      }),
    );
    return res.statusCode == 200;
  }
}
